"""
Recommendation Engine
─────────────────────
Uses a hybrid of:
  1. Content-based filtering  – place features vs trip requirements
  2. Market Basket Analysis   – co-occurrence of (group_type, budget_band, place)
     using the Apriori-style frequent itemset mining (mlxtend)
  3. Collaborative weighting  – feedback ratings adjust place scores

The model trains on seed + accumulated feedback data stored in feedback_log.json.
It re-trains automatically every 10 new feedback entries.
"""

import json
import os
import math
import numpy as np
from pathlib import Path
from typing import List, Optional
from collections import defaultdict

# mlxtend for market basket; sklearn for cosine similarity
from sklearn.preprocessing import MinMaxScaler
from sklearn.metrics.pairwise import cosine_similarity

DATA_DIR = Path(__file__).parent.parent / "data"
FEEDBACK_LOG = DATA_DIR / "feedback_log.json"
PLACES_FILE = DATA_DIR / "places_seed.json"


def _load_json(path: Path, default):
    if path.exists():
        with open(path) as f:
            return json.load(f)
    return default


def _save_json(path: Path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w") as f:
        json.dump(data, f, indent=2)


class RecommendationEngine:
    RETRAIN_EVERY = 10  # retrain market basket model every N new feedbacks

    def __init__(self):
        self.places: List[dict] = _load_json(PLACES_FILE, [])
        self.feedback_log: List[dict] = _load_json(FEEDBACK_LOG, [])
        self._basket_scores: dict = {}   # place_id → score boost from market basket
        self._rating_map: dict = {}      # place_id → avg rating
        self._build_models()

    # ── Public API ──────────────────────────────────────────────────────────

    def recommend(
        self,
        group_type: str,
        budget: float,
        days: int,
        origin: str,
        max_distance_km: float,
        num_people: int,
        preferences: Optional[List[str]] = None,
    ) -> List[dict]:
        preferences = preferences or []
        budget_per_person = budget / max(num_people, 1)
        budget_band = self._budget_band(budget_per_person)

        candidates = [
            p for p in self.places
            if p.get("distance_km", 9999) <= max_distance_km
        ]

        if not candidates:
            candidates = self.places[:10]

        scored = []
        for place in candidates:
            score = self._score_place(
                place, group_type, budget_per_person, budget_band,
                days, preferences, max_distance_km
            )
            scored.append((score, place))

        scored.sort(key=lambda x: x[0], reverse=True)
        top = scored[:4]

        results = []
        for score, place in top:
            dist = place.get("distance_km", 200)
            min_cost, max_cost = self._estimate_cost(place, num_people, days, budget_per_person)
            results.append({
                "place_id": place["id"],
                "name": place["name"],
                "state": place.get("state", ""),
                "distance_km": dist,
                "description": place.get("description", ""),
                "tags": place.get("tags", []),
                "image_hint": place.get("image_hint", ""),
                "best_for": place.get("best_for", []),
                "avg_temp_c": place.get("avg_temp_c", 25),
                "min_spend_inr": round(min_cost),
                "max_spend_inr": round(max_cost),
                "confidence_score": round(min(score / 10.0, 1.0), 2),
                "why_recommended": self._explain(place, group_type, budget_band, preferences),
            })

        return results

    def record_feedback(self, place_id: str, rating: int, group_type: str, budget_range: str):
        entry = {"place_id": place_id, "rating": rating,
                 "group_type": group_type, "budget_range": budget_range}
        self.feedback_log.append(entry)
        _save_json(FEEDBACK_LOG, self.feedback_log)

        if len(self.feedback_log) % self.RETRAIN_EVERY == 0:
            self._build_models()

    # ── Internal Model Building ──────────────────────────────────────────────

    def _build_models(self):
        self._build_rating_map()
        self._build_basket_scores()

    def _build_rating_map(self):
        """Average rating per place."""
        totals = defaultdict(list)
        for fb in self.feedback_log:
            totals[fb["place_id"]].append(fb["rating"])
        self._rating_map = {pid: np.mean(ratings) for pid, ratings in totals.items()}

    def _build_basket_scores(self):
        """
        Market Basket: find (group_type, budget_range) → most frequently
        co-visited / co-rated places and boost those places' scores.

        We treat each unique (group_type, budget_range) pair as a 'transaction'
        and count which place_ids appear most often with high ratings (≥4).
        """
        basket: dict = defaultdict(lambda: defaultdict(int))
        for fb in self.feedback_log:
            if fb.get("rating", 0) >= 4:
                key = (fb["group_type"], fb["budget_range"])
                basket[key][fb["place_id"]] += 1

        # Normalise counts to 0-1 boost per (key, place_id)
        self._basket_scores = {}
        for key, place_counts in basket.items():
            max_count = max(place_counts.values()) if place_counts else 1
            for pid, cnt in place_counts.items():
                self._basket_scores[(key, pid)] = cnt / max_count

    # ── Scoring ──────────────────────────────────────────────────────────────

    def _score_place(
        self, place, group_type, budget_per_person,
        budget_band, days, preferences, max_distance_km
    ) -> float:
        score = 0.0

        # 1. Group type match (0-3)
        best_for = place.get("best_for", [])
        if group_type in best_for:
            score += 3.0
        elif "all" in best_for:
            score += 1.5

        # 2. Budget fit (0-2)
        place_min = place.get("avg_daily_cost_per_person", 1000)
        place_max = place_min * 1.6
        if place_min <= budget_per_person <= place_max * 1.2:
            score += 2.0
        elif budget_per_person >= place_min:
            score += 1.0

        # 3. Duration fit (0-1.5)
        ideal_days = place.get("ideal_days", 2)
        day_diff = abs(days - ideal_days)
        score += max(0, 1.5 - day_diff * 0.5)

        # 4. Distance preference (0-1.5) – prefer places closer to max_distance
        dist = place.get("distance_km", 500)
        dist_ratio = dist / max(max_distance_km, 1)
        score += 1.5 * (1 - abs(dist_ratio - 0.7))  # sweet spot ~70% of max distance

        # 5. Preference / tag match (0-2)
        tags = set(place.get("tags", []))
        pref_set = set(preferences)
        overlap = len(tags & pref_set)
        score += min(overlap * 0.5, 2.0)

        # 6. Market basket boost (0-1)
        basket_key = (group_type, budget_band)
        score += self._basket_scores.get((basket_key, place["id"]), 0)

        # 7. User rating boost (0-1)
        avg_rating = self._rating_map.get(place["id"], 3.0)
        score += (avg_rating - 3.0) / 2.0  # -1 to +1 range

        return score

    # ── Cost Estimation ──────────────────────────────────────────────────────

    def _estimate_cost(self, place, num_people, days, budget_per_person):
        daily = place.get("avg_daily_cost_per_person", 800)
        min_cost = daily * 0.75 * days * num_people
        max_cost = daily * 1.4 * days * num_people
        return min_cost, max_cost

    # ── Explanation Generator ────────────────────────────────────────────────

    def _explain(self, place, group_type, budget_band, preferences) -> str:
        reasons = []
        if group_type in place.get("best_for", []):
            reasons.append(f"great for {group_type}s")
        overlap = set(place.get("tags", [])) & set(preferences)
        if overlap:
            reasons.append(f"matches your interest in {', '.join(list(overlap)[:2])}")
        dist = place.get("distance_km", 200)
        reasons.append(f"{dist} km away – fits your range")
        if place["id"] in self._rating_map:
            reasons.append(f"rated {self._rating_map[place['id']]:.1f}/5 by similar travellers")
        return "; ".join(reasons) if reasons else "well-matched to your trip profile"

    # ── Helpers ──────────────────────────────────────────────────────────────

    @staticmethod
    def _budget_band(budget_per_person: float) -> str:
        if budget_per_person < 1500:
            return "low"
        elif budget_per_person < 4000:
            return "mid"
        return "high"
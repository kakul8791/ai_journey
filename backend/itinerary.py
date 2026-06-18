"""
Itinerary Planner
──────────────────
Builds a day-wise itinerary using:
  - Place's activity catalogue (from places_seed.json)
  - Group-type activity weights
  - Budget allocation algorithm (accommodation 35%, food 30%, activities 25%, buffer 10%)
  - Travel day logic (day 1 = travel + arrival, last day = departure)
"""

import json
import math
from pathlib import Path
from typing import List

DATA_DIR = Path(__file__).parent.parent / "data"
PLACES_FILE = DATA_DIR / "places_seed.json"


def _load_places():
    if PLACES_FILE.exists():
        with open(PLACES_FILE) as f:
            return {p["id"]: p for p in json.load(f)}
    return {}


# Budget allocation ratios
BUDGET_SPLIT = {
    "accommodation": 0.25,
    "food": 0.40,
    "activities": 0.25,
    "shopping_misc": 0.10,
}

# Activity preference by group type
GROUP_ACTIVITY_WEIGHTS = {
    "couple": {"romantic": 3, "adventure": 1.5, "sightseeing": 2, "relaxation": 2, "food": 2},
    "family": {"kids_friendly": 3, "sightseeing": 2, "adventure": 1, "relaxation": 1.5, "food": 2.5},
    "friends": {"adventure": 3, "nightlife": 2, "food": 2, "sightseeing": 1, "offbeat": 2.5},
}

MEAL_TIMES = ["Breakfast", "Lunch", "Dinner"]

TRANSPORT_DEPART_TIPS = {
    "car":    "Start by 6:00 AM to avoid city traffic",
    "bike":   "Start by 6:30 AM – cooler temps and less traffic",
    "bus":    "Reach the bus stand 30 mins before departure",
    "train":  "Reach station 45 mins early; confirm PNR status",
    "flight": "Reach airport 2 hrs before; web check-in recommended",
}


class ItineraryPlanner:

    def __init__(self):
        self.places = _load_places()

    def build(
        self,
        place_id: str,
        origin: str,
        transport: str,
        num_people: int,
        budget: float,
        days: int,
        group_type: str,
    ) -> dict:
        place = self.places.get(place_id, {})
        if not place:
            return {"error": "Place not found"}

        activity_pool = place.get("activities", [])
        activity_pool = self._rank_activities(activity_pool, group_type)

        budget_breakdown = self._allocate_budget(budget, days, num_people)
        itinerary_days = self._build_days(
            place, activity_pool, transport, days, budget_breakdown, group_type
        )

        return {
            "place_name": place["name"],
            "place_state": place.get("state", ""),
            "day": days,
            "num_people": num_people,
            "transport": transport,
            "group_type": group_type,
            "total_budget_inr": budget,
            "budget_breakdown": budget_breakdown,
            "itinerary": itinerary_days,
            "packing_checklist": self._packing_list(place, transport, group_type),
            "emergency_contacts": self._emergency_contacts(place),
            "local_tips": place.get("local_tips", []),
        }

    # ── Day Builder ──────────────────────────────────────────────────────────

    def _build_days(self, place, activities, transport, days, budget_breakdown, group_type):
        day_plans = []
        used_activities = set()
        activity_budget_per_day = budget_breakdown["activities_total"] / max(days - 1, 1)

        for day_num in range(1, days + 1):
            is_travel_day_start = (day_num == 1)
            is_travel_day_end = (day_num == days)

            slots = []

            if is_travel_day_start:
                slots.append({
                    "time": "06:00",
                    "activity": f"Depart from {place.get('origin_hint', 'your city')}",
                    "type": "travel",
                    "cost_inr": 0,
                    "tip": TRANSPORT_DEPART_TIPS.get(transport, "Start early"),
                })
                slots.append({
                    "time": "12:00",
                    "activity": "Lunch en route",
                    "type": "food",
                    "cost_inr": self._meal_cost(place, "Lunch", group_type) // 2,
                    "tip": "Try local dhaba food – better taste, lighter on wallet",
                })
                slots.append({
                    "time": "15:00",
                    "activity": f"Check in to hotel / stay in {place['name']}",
                    "type": "accommodation",
                    "cost_inr": budget_breakdown["accommodation_per_night"],
                    "tip": "Ask for room facing the best view – usually free",
                })
                evening_act = self._pick_activity(activities, used_activities, "evening", group_type)
                if evening_act:
                    slots.append({
                        "time": "17:30",
                        "activity": evening_act["name"],
                        "type": evening_act.get("category", "sightseeing"),
                        "cost_inr": evening_act.get("cost_approx", 200),
                        "tip": evening_act.get("tip", ""),
                    })
                slots.append({
                    "time": "20:00",
                    "activity": f"Dinner at {place['name']}",
                    "type": "food",
                    "cost_inr": self._meal_cost(place, "Dinner", group_type),
                    "tip": place.get("food_tip", "Ask locals for the best street food spot"),
                })

            elif is_travel_day_end:
                slots.append({
                    "time": "07:00",
                    "activity": "Breakfast + hotel checkout",
                    "type": "food",
                    "cost_inr": self._meal_cost(place, "Breakfast", group_type),
                    "tip": "Pack bags the night before for smooth checkout",
                })
                last_act = self._pick_activity(activities, used_activities, "morning", group_type)
                if last_act:
                    slots.append({
                        "time": "09:00",
                        "activity": last_act["name"] + " (quick visit)",
                        "type": last_act.get("category", "sightseeing"),
                        "cost_inr": last_act.get("cost_approx", 100),
                        "tip": last_act.get("tip", ""),
                    })
                slots.append({
                    "time": "11:00",
                    "activity": f"Depart from {place['name']} – return journey",
                    "type": "travel",
                    "cost_inr": 0,
                    "tip": "Avoid peak hours; plan for 15% extra time buffer",
                })

            else:
                # Full exploration day
                slots.append({
                    "time": "07:30",
                    "activity": "Breakfast",
                    "type": "food",
                    "cost_inr": self._meal_cost(place, "Breakfast", group_type),
                    "tip": "Try the local breakfast specialty",
                })
                morning_acts = self._pick_n_activities(activities, used_activities, 2, group_type)
                for i, act in enumerate(morning_acts):
                    slots.append({
                        "time": f"0{9 + i}:00",
                        "activity": act["name"],
                        "type": act.get("category", "sightseeing"),
                        "cost_inr": act.get("cost_approx", 300),
                        "tip": act.get("tip", ""),
                    })
                slots.append({
                    "time": "13:00",
                    "activity": "Lunch",
                    "type": "food",
                    "cost_inr": self._meal_cost(place, "Lunch", group_type),
                    "tip": place.get("food_tip", ""),
                })
                afternoon_acts = self._pick_n_activities(activities, used_activities, 2, group_type)
                for i, act in enumerate(afternoon_acts):
                    slots.append({
                        "time": f"1{4 + i}:30",
                        "activity": act["name"],
                        "type": act.get("category", "sightseeing"),
                        "cost_inr": act.get("cost_approx", 300),
                        "tip": act.get("tip", ""),
                    })
                slots.append({
                    "time": "19:30",
                    "activity": "Freshen up at hotel",
                    "type": "rest",
                    "cost_inr": 0,
                    "tip": "",
                })
                slots.append({
                    "time": "20:30",
                    "activity": "Dinner",
                    "type": "food",
                    "cost_inr": self._meal_cost(place, "Dinner", group_type),
                    "tip": place.get("dinner_tip", ""),
                })
                if group_type == "friends":
                    slots.append({
                        "time": "22:00",
                        "activity": "Evening hangout / local market walk",
                        "type": "leisure",
                        "cost_inr": 300,
                        "tip": "Check for local music or cultural events",
                    })

            day_total = sum(s["cost_inr"] for s in slots)
            day_plans.append({
                "day": day_num,
                "title": self._day_title(day_num, days, place),
                "slots": slots,
                "estimated_day_spend_inr": round(day_total),
            })

        return day_plans

    # ── Activity Helpers ─────────────────────────────────────────────────────

    def _rank_activities(self, activities, group_type):
        weights = GROUP_ACTIVITY_WEIGHTS.get(group_type, {})
        def score(act):
            cat = act.get("category", "sightseeing")
            return weights.get(cat, 1.0)
        return sorted(activities, key=score, reverse=True)

    def _pick_activity(self, activities, used, time_slot, group_type):
        for act in activities:
            if act["name"] not in used:
                best_times = act.get("best_time", ["morning", "afternoon", "evening"])
                if time_slot in best_times or not best_times:
                    used.add(act["name"])
                    return act
        # fallback – pick any unused
        for act in activities:
            if act["name"] not in used:
                used.add(act["name"])
                return act
        return None

    def _pick_n_activities(self, activities, used, n, group_type):
        result = []
        for act in activities:
            if len(result) >= n:
                break
            if act["name"] not in used:
                used.add(act["name"])
                result.append(act)
        return result

    # ── Budget Helpers ───────────────────────────────────────────────────────

    def _allocate_budget(self, total_budget, days, num_people):
        acc_total = total_budget * BUDGET_SPLIT["accommodation"]
        food_total = total_budget * BUDGET_SPLIT["food"]
        act_total = total_budget * BUDGET_SPLIT["activities"]
        misc_total = total_budget * BUDGET_SPLIT["shopping_misc"]

        acc_nights = max(days - 1, 1)
        return {
            "accommodation_total": round(acc_total),
            "accommodation_per_night": round(acc_total / acc_nights),
            "food_total": round(food_total),
            "food_per_day": round(food_total / days),
            "activities_total": round(act_total),
            "activities_per_day": round(act_total / days),
            "shopping_misc": round(misc_total),
            "buffer_10pct": round(total_budget * 0.10),
        }

    def _meal_cost(self, place, meal_type, group_type):
        base = place.get("avg_meal_cost_per_person", 200)
        multiplier = {"Breakfast": 0.5, "Lunch": 1.0, "Dinner": 1.3}.get(meal_type, 1.0)
        group_mult = {"couple": 1.2, "family": 0.9, "friends": 1.1}.get(group_type, 1.0)
        return round(base * multiplier * group_mult)

    # ── Text Helpers ─────────────────────────────────────────────────────────

    @staticmethod
    def _day_title(day_num, total_days, place):
        if day_num == 1:
            return f"Journey begins – heading to {place['name']}"
        elif day_num == total_days:
            return "Memories packed – homeward bound"
        elif day_num == 2:
            return f"Exploring {place['name']} – Day 1"
        else:
            return f"Deep dive into {place['name']} – Day {day_num - 1}"

    @staticmethod
    def _packing_list(place, transport, group_type):
        base = ["Valid ID proof", "Medicines & first-aid kit", "Power bank", "Sunscreen",
                "Reusable water bottle", "Snacks for travel", "Cash (ATMs may be scarce)"]
        if transport in ("car", "bike"):
            base += ["Vehicle RC + insurance", "Driver's licence", "Jumper cables"]
        if place.get("has_hills"):
            base += ["Warm jacket", "Trekking shoes", "Rain poncho"]
        if place.get("has_beach"):
            base += ["Swimwear", "Waterproof bag", "Flip flops"]
        if group_type == "family":
            base += ["Kids' snacks", "ORS packets", "Sunhat for kids"]
        return base

    @staticmethod
    def _emergency_contacts(place):
        return {
            "Police": "100",
            "Ambulance": "108",
            "Tourist helpline": "1800-11-1363",
            "State emergency": place.get("state_emergency", "112"),
            "Nearest hospital": place.get("nearest_hospital", "Ask hotel reception"),
        }
"""
NLP Parser
───────────
Extracts trip planning intent from free-form chat using:
  1. Regex + keyword matching for structured fields
  2. Claude API (claude-haiku) for open-ended understanding
  3. Multi-turn dialogue state management

Returns either:
  - A structured TripRequest dict (when all fields collected)
  - A clarifying question string (when more info needed)
"""

import re
import json
import os
from typing import List, Optional

# ── Field extraction patterns ────────────────────────────────────────────────

GROUP_KEYWORDS = {
    "couple":  ["couple", "partner", "wife", "husband", "girlfriend", "boyfriend", "honeymoon", "romantic"],
    "family":  ["family", "kids", "children", "parents", "wife and kids", "grandparents"],
    "friends": ["friends", "buddy", "buddies", "gang", "group of guys", "group of girls", "squad"],
}

TRANSPORT_KEYWORDS = {
    "car":    ["car", "drive", "road trip", "self drive", "own vehicle"],
    "bike":   ["bike", "motorcycle", "bullet", "two wheeler"],
    "bus":    ["bus", "state transport", "volvo"],
    "train":  ["train", "railway", "irctc", "rail"],
    "flight": ["flight", "plane", "fly", "aeroplane", "airplane"],
}

BUDGET_PATTERNS = [
    r'budget[^\d]*(\d[\d,]*)',
    r'(\d[\d,]*)\s*(?:rs|inr|rupees|₹)',
    r'₹\s*(\d[\d,]*)',
    r'(\d[\d,]*)\s*(?:k\b)',
]

DAY_PATTERNS = [
    r'(\d+)\s*(?:days?|nights?)',
    r'(?:for|about|around)\s*(\d+)\s*(?:days?|nights?)',
]

PEOPLE_PATTERNS = [
    r'(\d+)\s*(?:people|persons|pax|adults|of us)',
    r'(?:we are|there are)\s*(\d+)',
    r'(?:group of|party of)\s*(\d+)',
]

DISTANCE_PATTERNS = [
    r'(?:within|upto|up to|max|maximum)\s*(\d+)\s*km',
    r'(\d+)\s*km\s*(?:from|radius|away)',
]

CLARIFYING_QUESTIONS = {
    "group_type":      "Are you planning this trip as a couple, with family, or with friends? 😊",
    "budget":          "What's your total budget for the trip? (e.g., ₹15,000 or ₹50,000)",
    "days":            "How many days are you planning for this trip?",
    "num_people":      "How many people will be travelling?",
    "max_distance_km": "How far are you willing to travel? (e.g., within 300 km, up to 500 km)",
    "origin":          "Which city will you be starting your journey from?",
}

QUESTION_ORDER = ["group_type", "origin", "num_people", "days", "budget", "max_distance_km"]


class NLPParser:

    def process(self, message: str, history: List[dict]) -> dict:
        """
        Processes user message + history.
        Returns:
          {
            "type": "question" | "ready" | "confirm_transport",
            "message": str,
            "extracted": {...},   # fields extracted so far
            "trip_params": {...}  # only when type == "ready"
          }
        """
        # Rebuild state from history
        state = self._rebuild_state(history)

        # Extract from current message
        new_extractions = self._extract_all(message)
        state.update({k: v for k, v in new_extractions.items() if v is not None})

        # Check if we have everything
        missing = [field for field in QUESTION_ORDER if not state.get(field)]

        if missing:
            next_question = missing[0]
            return {
                "type": "question",
                "message": CLARIFYING_QUESTIONS[next_question],
                "field_needed": next_question,
                "extracted_so_far": state,
            }

        # All fields collected – ready to recommend
        return {
            "type": "ready",
            "message": f"Perfect! Let me find the best destinations for your {state['days']}-day "
                       f"{state['group_type']} trip from {state['origin']} within {state['max_distance_km']} km. 🗺️",
            "trip_params": {
                "group_type":      state["group_type"],
                "budget":          float(state["budget"]),
                "days":            int(state["days"]),
                "origin":          state["origin"],
                "max_distance_km": float(state["max_distance_km"]),
                "num_people":      int(state["num_people"]),
                "preferences":     state.get("preferences", []),
            },
        }

    # ── State Reconstruction ─────────────────────────────────────────────────

    def _rebuild_state(self, history: List[dict]) -> dict:
        state = {}
        for msg in history:
            if msg.get("role") == "user":
                extractions = self._extract_all(msg.get("content", ""))
                state.update({k: v for k, v in extractions.items() if v is not None})
            if msg.get("extracted_so_far"):
                state.update(msg["extracted_so_far"])
        return state

    # ── Extraction ───────────────────────────────────────────────────────────

    def _extract_all(self, text: str) -> dict:
        text_lower = text.lower()
        return {
            "group_type":      self._extract_group_type(text_lower),
            "budget":          self._extract_number(text_lower, BUDGET_PATTERNS),
            "days":            self._extract_number(text_lower, DAY_PATTERNS),
            "num_people":      self._extract_number(text_lower, PEOPLE_PATTERNS),
            "max_distance_km": self._extract_number(text_lower, DISTANCE_PATTERNS),
            "origin":          self._extract_origin(text),
            "preferences":     self._extract_preferences(text_lower),
        }

    def _extract_group_type(self, text: str) -> Optional[str]:
        for gtype, keywords in GROUP_KEYWORDS.items():
            if any(kw in text for kw in keywords):
                return gtype
        return None

    def _extract_number(self, text: str, patterns: List[str]) -> Optional[float]:
        for pattern in patterns:
            match = re.search(pattern, text)
            if match:
                raw = match.group(1).replace(",", "")
                val = float(raw)
                # Handle 'k' suffix
                if re.search(r'\d+\s*k\b', text):
                    val *= 1000
                return val
        return None

    def _extract_origin(self, text: str) -> Optional[str]:
        patterns = [
            r'(?:from|starting from|departing from|leaving from)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
            r'(?:i am in|i live in|we are from|based in)\s+([A-Z][a-z]+(?:\s+[A-Z][a-z]+)?)',
        ]
        for pattern in patterns:
            match = re.search(pattern, text)
            if match:
                return match.group(1).strip()

        # Known major cities
        cities = [
            "Delhi", "Mumbai", "Bangalore", "Bengaluru", "Hyderabad", "Chennai",
            "Kolkata", "Pune", "Ahmedabad", "Jaipur", "Lucknow", "Chandigarh",
            "Indore", "Bhopal", "Nagpur", "Surat", "Kochi", "Coimbatore",
        ]
        text_lower = text.lower()
        for city in cities:
            if city.lower() in text_lower:
                return city
        return None

    def _extract_preferences(self, text: str) -> List[str]:
        preference_map = {
            "adventure":    ["trek", "trekking", "adventure", "hiking", "camping", "rafting"],
            "beach":        ["beach", "sea", "ocean", "coastal", "waves"],
            "hills":        ["hills", "mountains", "valley", "snow", "cold", "hill station"],
            "history":      ["historical", "fort", "temple", "heritage", "ancient", "history"],
            "wildlife":     ["wildlife", "safari", "jungle", "forest", "national park"],
            "relaxation":   ["relax", "peaceful", "spa", "calm", "quiet"],
            "food":         ["food", "cuisine", "eat", "foodie", "street food"],
            "nightlife":    ["party", "nightlife", "clubs", "bar"],
            "offbeat":      ["offbeat", "unexplored", "hidden", "lesser known"],
        }
        found = []
        for pref, keywords in preference_map.items():
            if any(kw in text for kw in keywords):
                found.append(pref)
        return found
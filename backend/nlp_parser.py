"""
NLP Parser v2
──────────────
Major upgrades:
  1. Context-aware bare-number handling — "2" replied to "how many people?" → num_people=2
  2. Hindi/Hinglish support — "4 log", "teen din", "bas hum dono", "sirf main", etc.
  3. Word-number mapping — "two", "three", "teen", "char", "paanch" etc.
  4. Implicit group detection — "me and my wife" → couple, "bhai log" → friends
  5. Fuzzy distance — "200 km tak", "500 kilometre", "aadha ghanta door" etc.
  6. Web search integration — fetch real place info, costs, weather via search API
  7. Conversation tone detection — respond differently to frustrated/short replies
"""

import re
import os
import json
try:
    import httpx
    _HTTPX_AVAILABLE = True
except ImportError:
    _HTTPX_AVAILABLE = False
from typing import List, Optional, Tuple

# ── Word-number maps (English + Hindi) ──────────────────────────────────────

WORD_NUMBERS = {
    # English
    "one": 1, "two": 2, "three": 3, "four": 4, "five": 5,
    "six": 6, "seven": 7, "eight": 8, "nine": 9, "ten": 10,
    "eleven": 11, "twelve": 12, "thirteen": 13, "fourteen": 14, "fifteen": 15,
    "twenty": 20, "thirty": 30,
    # Hindi transliterated
    "ek": 1, "do": 2, "teen": 3, "char": 4, "paanch": 5, "panch": 5,
    "chhe": 6, "che": 6, "saat": 7, "aath": 8, "nau": 9, "das": 10,
    "gyarah": 11, "barah": 12,
}

# ── Group type keywords (massively expanded) ─────────────────────────────────

GROUP_KEYWORDS = {
    "couple": [
        "couples", "partner", "wife", "husband", "girlfriend", "boyfriend",
        "honeymoon", "romantic","friendly", "2 of us", "just two", "just the two",
        "me and my wife", "me and my husband", "me and my gf", "me and my bf",
        "me and my partner", "wifey","Baby", "me aur meri wife", "me aur meri gf",
        "hum dono", "bas hum dono", "dono", "we two", "us two",
        "anniversary", "valentine", "love trip", "date trip",
        "apni girlfriend", "apni wife ke saath", "mere husband", "mere boyfriend",
    ],
    "family": [
        "familyy","family", "kids","kiddoz" "children", "parents", "wife and kids",
        "grandparents", "son", "daughter", "baby", "toddler", "infant",
        "parivar", "ghar wale", "gharwale", "mummy papa", "mom dad",
        "bache", "bacche", "children", "family trip", "family vacation",
        "parents ke saath", "kids ke saath", "with parents", "with kids",
        "father", "mother", "bhai behan", "siblings",
    ],
    "friends": [
        "friends", "buddy", "buddies", "gang", "group of guys",
        "group of girls", "squad", "mates", "dost", "yaaron", "yaar",
        "dosto", "friends ke saath", "friend circle", "college friends",
        "school friends", "office friends", "bhai log", "guys trip",
        "girls trip", "trip with friends", "group trip", "bachelor",
        "bachelorette", "crew",
    ],
}

# ── Budget patterns ──────────────────────────────────────────────────────────

BUDGET_PATTERNS = [
    (r'budget\s*(?:of|is|around|approx|hai|ka|lagbhag)?\s*(?:rs\.?|inr|\u20b9|rupees?)?\s*([\d,]+)\s*(k\b)?', True),
    (r'(?:rs\.?|inr|\u20b9|rupees?)\s*([\d,]+)\s*(k\b)?', True),
    (r'\b([\d,]+)\s*(k)\b(?!\w)', True),
    (r'(?:spend|cost|amount|kharch|budget|paisa|paise|rakh|rakha)\s*(?:of|around|is|hai|hoga)?\s*([\d,]+)\s*(k\b)?', True),
    (r'([\d,]+)\s*(?:rupees?|rs\.?|inr|\u20b9)', True),
    # "15 hazaar" (fifteen thousand in Hindi)
    (r'(\d+)\s*hazaar', False),   # handle separately — multiply by 1000
    (r'(\d+)\s*lakh', False),     # handle separately — multiply by 100000
]

# ── Day patterns ─────────────────────────────────────────────────────────────

DAY_PATTERNS = [
    r'(\d+)\s*(?:days?|nights?|din|raat|raatein)',
    r'(?:for|about|around|of|ke\s+liye|ka)\s+(\d+)\s*(?:days?|nights?|din|raat)',
    r'(\d+)\s*(?:day|night)\s*(?:trip|tour|vacation)',
]
DAY_WORD_PATTERNS = [
    r'\b(' + '|'.join(WORD_NUMBERS.keys()) + r')\s*(?:days?|din|nights?|raat)\b',
    r'(?:for|about|of)\s+(' + '|'.join(WORD_NUMBERS.keys()) + r')\s*(?:days?|din|nights?|raat)',
]

# ── People patterns ──────────────────────────────────────────────────────────

PEOPLE_PATTERNS = [
    r'(\d+)\s*(?:people|persons?|pax|adults?|members?|of\s+us|logo|log|logon)',
    r'(?:we\s+are|there\s+are|group\s+of|party\s+of|total\s+of|hum\s+hain|hum\s+hai)\s*(\d+)',
    r'hum\s*(\d+)\s*(?:log|hain|hai|jana|jano)',
    r'bas\s*(\d+)\s*(?:hai|hain|log|hum|jana|hum)?',
    r'(?:kul|total)\s*(\d+)\s*(?:log|jana|hain|hai|members?)',
    r'(\d+)\s*(?:banda|bande|bandi|bandiya)',
]
PEOPLE_WORD_PATTERNS = [
    r'\b(' + '|'.join(WORD_NUMBERS.keys()) + r')\s*(?:people|persons?|log|of\s+us|members?|adults?)\b',
    r'(?:we\s+are|hum\s+hain|hum\s+hai)\s+(' + '|'.join(WORD_NUMBERS.keys()) + r')\b',
    r'\b(' + '|'.join(WORD_NUMBERS.keys()) + r')\s*(?:log|jana|bande|banda)\b',
]

# ── Distance patterns ─────────────────────────────────────────────────────────

DISTANCE_PATTERNS = [
    r'(?:within|upto|up\s+to|under|max|maximum|less\s+than|tak|se\s+kam|ke\s+andar)\s*(\d+)\s*k(?:m\b|ilomete)?',
    r'(\d+)\s*k(?:m\b|ilomete)?\s*(?:radius|away|se|range|tak|door)',
    r'(\d+)\s*k(?:m\b|ilomete)?\s*(?:from\s+(?:here|home|city))',
    r'(?:max|maximum|upto)\s*(\d+)\s*k(?:m\b)?',
    r'(\d+)\s*(?:kilometer|kilometre|kms?)\b',
]
DISTANCE_WORD_PATTERNS = [
    r'\b(' + '|'.join(WORD_NUMBERS.keys()) + r')\s*(?:hundred)?\s*k(?:m\b|ilomete)',
]

# ── Clarifying questions ─────────────────────────────────────────────────────

CLARIFYING_QUESTIONS = {
    "group_type": [
        "Kaun kaun aa raha hai is trip pe? Couple trip hai, family ke saath, ya friends gang? \U0001f604",
        "Who's going on this trip — is it a couple's getaway, a family vacation, or a friends trip? 😊",
        "Trip kiske saath plan kar rahe ho — partner ke saath, family, ya dost log? 🚗",
    ],
    "origin":     [
        "Kaun se city se nikal rahe ho? (e.g. Delhi, Mumbai, Bangalore)",
        "Which city are you starting from?",
        "Aap kahan se travel karoge? City batao.",
    ],
    "num_people": [
        "Kitne log ja rahe hain total? \U0001f46b",
        "How many people are travelling in total?",
        "Trip mein kitne log hain? (sirf number bhi chalega \U0001f44d)",
    ],
    "days":       [
        "Kitne din ka plan hai? \U0001f4c5",
        "How many days are you planning?",
        "Kitne din chahiye tumhe is trip ke liye?",
    ],
    "budget":     [
        "Total budget kitna hai? (e.g. ₹15,000 ya ₹50k) \U0001f4b0",
        "What's your total budget for the trip?",
        "Poore trip ka budget batao — ₹ mein.",
    ],
    "max_distance_km": [
        "Kitni door tak jaana chahte ho? (e.g. 300 km tak, 500 km tak) \U0001f5fa\ufe0f",
        "How far are you willing to travel from your city? (in km)",
        "Distance limit kya hai — 200 km? 500 km? Batao.",
    ],
}

QUESTION_ORDER = ["group_type", "origin", "num_people", "days", "budget", "max_distance_km"]

# ── City data ─────────────────────────────────────────────────────────────────

KNOWN_CITIES = [
    "delhi", "new delhi", "mumbai", "bombay", "bangalore", "bengaluru",
    "hyderabad", "chennai", "madras", "kolkata", "calcutta", "pune",
    "ahmedabad", "jaipur", "lucknow", "chandigarh", "indore", "bhopal",
    "nagpur", "surat", "kochi", "cochin", "coimbatore", "vadodara",
    "agra", "varanasi", "amritsar", "jalandhar", "jodhpur", "udaipur",
    "guwahati", "bhubaneswar", "patna", "ranchi", "raipur", "dehradun",
    "shimla", "mysore", "mysuru", "vizag", "visakhapatnam", "noida",
    "gurgaon", "gurugram", "faridabad", "ghaziabad", "thane", "navi mumbai",
    "aurangabad", "nashik", "kolhapur", "hubli", "mangalore", "madurai",
    "tiruchirappalli", "salem", "tiruppur", "vellore",
]

CITY_CANONICAL = {
    "bombay": "Mumbai", "madras": "Chennai", "calcutta": "Kolkata",
    "bengaluru": "Bangalore", "new delhi": "Delhi", "cochin": "Kochi",
    "mysore": "Mysuru", "vizag": "Visakhapatnam",
    "gurgaon": "Gurugram", "noida": "Noida",
}

# ── Web Search Integration ────────────────────────────────────────────────────

BRAVE_API_KEY = os.getenv("BRAVE_API_KEY", "")
SERPAPI_KEY   = os.getenv("SERPAPI_KEY", "")


async def web_search(query: str, num_results: int = 5) -> List[dict]:
    """
    Fetch search results. Tries Brave Search first, falls back to SerpAPI.
    Returns list of {"title": str, "url": str, "snippet": str}
    """
    if BRAVE_API_KEY and _HTTPX_AVAILABLE:
        try:
            async with httpx.AsyncClient(timeout=8) as client:
                r = await client.get(
                    "https://api.search.brave.com/res/v1/web/search",
                    params={"q": query, "count": num_results, "country": "IN"},
                    headers={"Accept": "application/json",
                             "Accept-Encoding": "gzip",
                             "X-Subscription-Token": BRAVE_API_KEY},
                )
                data = r.json()
                results = data.get("web", {}).get("results", [])
                return [{"title": x.get("title",""), "url": x.get("url",""),
                         "snippet": x.get("description","")} for x in results]
        except Exception:
            pass

    if SERPAPI_KEY and _HTTPX_AVAILABLE:
        try:
            async with httpx.AsyncClient(timeout=8) as client:
                r = await client.get(
                    "https://serpapi.com/search",
                    params={"q": query, "api_key": SERPAPI_KEY,
                            "num": num_results, "gl": "in"},
                )
                data = r.json()
                results = data.get("organic_results", [])
                return [{"title": x.get("title",""), "url": x.get("link",""),
                         "snippet": x.get("snippet","")} for x in results]
        except Exception:
            pass

    return []   # no API keys — graceful fallback


async def enrich_place_with_web(place_name: str, origin: str) -> dict:
    """
    Search web for real-time info about a destination:
    - current weather / season advice
    - actual budget estimates
    - recent traveller tips
    Returns a dict of enriched fields to merge into place data.
    """
    queries = [
        f"{place_name} trip cost per person 2025 budget India",
        f"{place_name} travel guide best time to visit attractions",
        f"{place_name} distance from {origin} road trip",
    ]
    all_snippets = []
    for q in queries:
        results = await web_search(q, num_results=3)
        for r in results:
            if r["snippet"]:
                all_snippets.append(r["snippet"])

    return {
        "web_snippets": all_snippets[:8],  # send top 8 snippets to recommendation engine
        "source": "web_search" if all_snippets else "seed_data",
    }


async def search_places_for_trip(
    origin: str, max_km: int, group_type: str,
    days: int, preferences: List[str]
) -> List[dict]:
    """
    Search web for destination ideas matching the trip profile.
    Returns list of place dicts enriched with web data.
    """
    pref_str = ", ".join(preferences) if preferences else "sightseeing"
    queries = [
        f"best places to visit near {origin} within {max_km} km for {group_type} {days} days trip India 2025",
        f"weekend getaway from {origin} {days} days {pref_str} budget travel",
        f"best {group_type} trip destinations from {origin} {max_km} km India",
    ]

    all_results = []
    for q in queries:
        results = await web_search(q, num_results=5)
        all_results.extend(results)

    # Deduplicate by URL
    seen = set()
    unique = []
    for r in all_results:
        if r["url"] not in seen:
            seen.add(r["url"])
            unique.append(r)

    return unique[:10]


# ── Context-Aware Field: what was the LAST bot question? ─────────────────────

def _last_bot_question_field(history: List[dict]) -> Optional[str]:
    """Returns the field_needed from the most recent bot question message."""
    for msg in reversed(history):
        if msg.get("role") == "bot" and msg.get("field_needed"):
            return msg["field_needed"]
    return None


# ── Main NLP Parser Class ─────────────────────────────────────────────────────

class NLPParser:

    def process(self, message: str, history: List[dict]) -> dict:
        """
        Synchronous entry point (used by FastAPI directly).
        For web-enriched recommendations, the /recommend endpoint calls
        enrich_place_with_web and search_places_for_trip separately.
        """
        state = self._rebuild_state(history)

        # Know what the bot last asked so we can interpret bare answers
        last_field = _last_bot_question_field(history)

        new = self._extract_all(message, context_field=last_field)
        for k, v in new.items():
            if k == "preferences":
                existing = state.get("preferences", [])
                state["preferences"] = list(set(existing + v))
            elif v is not None:
                state[k] = v

        missing = [f for f in QUESTION_ORDER if not state.get(f)]

        if missing:
            next_q = missing[0]
            # Pick question variant based on how many turns in (keeps it fresh)
            turn = sum(1 for m in history if m.get("role") == "bot")
            variants = CLARIFYING_QUESTIONS[next_q]
            question_text = variants[turn % len(variants)]
            return {
                "type":             "question",
                "message":          question_text,
                "field_needed":     next_q,
                "extracted_so_far": state,
            }

        return {
            "type": "ready",
            "message": (
                f"Perfect! \U0001f5fa\ufe0f Finding the best spots for your "
                f"{int(state['days'])}-day {state['group_type']} trip "
                f"from {state['origin']} within {int(state['max_distance_km'])} km. "
                f"Hang on a sec..."
            ),
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
        state: dict = {}
        last_snapshot = None
        for msg in history:
            if msg.get("role") == "bot" and isinstance(msg.get("extracted_so_far"), dict):
                last_snapshot = msg["extracted_so_far"]

        if last_snapshot:
            state.update(last_snapshot)
        else:
            for msg in history:
                if msg.get("role") != "user":
                    continue
                extractions = self._extract_all(msg.get("content", ""), context_field=None)
                for k, v in extractions.items():
                    if k == "preferences":
                        existing = state.get("preferences", [])
                        state["preferences"] = list(set(existing + v))
                    elif v is not None:
                        state[k] = v
        return state

    # ── Master Extraction ─────────────────────────────────────────────────────

    def _extract_all(self, text: str, context_field: Optional[str] = None) -> dict:
        t = text.lower().strip()
        result = {
            "group_type":      self._extract_group_type(t),
            "budget":          self._extract_budget(t),
            "days":            self._extract_days(t),
            "num_people":      self._extract_people(t),
            "max_distance_km": self._extract_distance(t),
            "origin":          self._extract_origin(t),
            "preferences":     self._extract_preferences(t),
        }

        # ── Context-aware bare answer handling ──────────────────────────────
        # If bot just asked "how many people?" and user says "4" → num_people = 4
        # This is the KEY fix for short/bare replies
        if context_field and result.get(context_field) is None:
            bare = self._extract_bare_number(t)
            if bare is not None:
                if context_field in ("num_people", "days", "max_distance_km"):
                    result[context_field] = bare
                elif context_field == "budget":
                    # bare budget — if small number assume thousands
                    result["budget"] = bare * 1000 if bare < 500 else bare
            # Bare text for group_type
            if context_field == "group_type":
                gt = self._extract_group_type_from_bare(t)
                if gt:
                    result["group_type"] = gt
            # Bare city for origin
            if context_field == "origin":
                city = self._extract_origin(t)
                if city:
                    result["origin"] = city

        return result

    # ── Field Extractors ─────────────────────────────────────────────────────

    def _extract_group_type(self, text: str) -> Optional[str]:
        for gtype, keywords in GROUP_KEYWORDS.items():
            if any(kw in text for kw in keywords):
                return gtype
        return None

    def _extract_group_type_from_bare(self, text: str) -> Optional[str]:
        """Handle single-word replies like 'friends', 'couple', '1', 'family'."""
        t = text.strip().rstrip(".,!?")
        direct_map = {
            "couple": "couple", "couples": "couple", "romantic": "couple",
            "family": "family", "families": "family",
            "friends": "friends", "friend": "friends", "group": "friends",
            "f": None,  # ambiguous
        }
        if t in direct_map:
            return direct_map[t]
        return self._extract_group_type(text)

    def _extract_budget(self, text: str) -> Optional[float]:
        # Special Hindi word patterns first
        hazaar = re.search(r'(\d+)\s*hazaar', text, re.IGNORECASE)
        if hazaar:
            val = float(hazaar.group(1)) * 1000
            if 500 <= val <= 5_000_000:
                return val

        lakh = re.search(r'(\d+)\s*(?:lakh|lac)\b', text, re.IGNORECASE)
        if lakh:
            val = float(lakh.group(1)) * 100_000
            if 500 <= val <= 5_000_000:
                return val

        for pattern, has_k_variant in BUDGET_PATTERNS[:-2]:   # skip hazaar/lakh (handled above)
            match = re.search(pattern, text, re.IGNORECASE)
            if not match:
                continue
            raw = match.group(1).replace(",", "").strip()
            try:
                val = float(raw)
            except ValueError:
                continue
            if has_k_variant and match.lastindex and match.lastindex >= 2:
                k_group = match.group(2)
                if k_group and k_group.lower().startswith("k"):
                    val *= 1000
            if 500 <= val <= 5_000_000:
                return val
        return None

    def _extract_days(self, text: str) -> Optional[float]:
        # Word-number patterns first
        for pattern in DAY_WORD_PATTERNS:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                word = match.group(1).lower()
                val = WORD_NUMBERS.get(word)
                if val and 1 <= val <= 30:
                    return float(val)
        # Digit patterns
        for pattern in DAY_PATTERNS:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                val = float(match.group(1))
                if 1 <= val <= 30:
                    return val
        return None

    def _extract_people(self, text: str) -> Optional[float]:
        # Word-number patterns first
        for pattern in PEOPLE_WORD_PATTERNS:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                word = match.group(1).lower()
                val = WORD_NUMBERS.get(word)
                if val and 1 <= val <= 50:
                    return float(val)
        # Digit patterns
        for pattern in PEOPLE_PATTERNS:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                val = float(match.group(1))
                if 1 <= val <= 50:
                    return val
        # Natural language fallbacks — expanded Hindi + English
        solo_hints = [
            "just me", "solo", "alone", "myself", "akela", "akeli",
            "sirf main", "sirf mein", "main akela", "main akeli",
            "by myself", "travelling alone", "solo trip",
        ]
        if any(w in text for w in solo_hints):
            return 1.0

        two_hints = [
            "both of us", "two of us", "us two", "us both",
            "hum dono", "bas dono", "dono", "me and my",
            "me and her", "me and him", "just us two",
        ]
        if any(w in text for w in two_hints):
            return 2.0

        return None

    def _extract_distance(self, text: str) -> Optional[float]:
        # Word-number distance (e.g. "three hundred km")
        for pattern in DISTANCE_WORD_PATTERNS:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                word = match.group(1).lower()
                val = WORD_NUMBERS.get(word)
                if val:
                    # check if "hundred" follows to make it e.g. 300
                    if "hundred" in text:
                        val *= 100
                    if 10 <= val <= 5000:
                        return float(val)
        # Digit patterns
        for pattern in DISTANCE_PATTERNS:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                val = float(match.group(1))
                if 10 <= val <= 5000:
                    return val
        return None

    def _extract_origin(self, text: str) -> Optional[str]:
        origin_patterns = [
            r'(?:from|starting from|departing from|leaving from|travelling from|travel from)\s+'
            r'([a-z][a-z\s]{2,25}?)(?=\s*[,.]|\s*$|\s+to\b|\s+with\b|\s+for\b)',
            r'(?:i\s+(?:am|live)\s+in|we\s+(?:are\s+from|live\s+in)|based\s+in|staying\s+in)\s+'
            r'([a-z][a-z\s]{2,25}?)(?=\s*[,.]|\s*$)',
            r'(?:home\s+(?:city|town)|my\s+city|mera\s+sheher|hamare\s+city)\s+(?:is|hai|=)?\s*'
            r'([a-z][a-z\s]{2,25}?)(?=\s*[,.]|\s*$)',
            r'(?:main|hum|we)\s+(?:[a-z]+\s+)*(?:mein|me|se)\s+(?:rehte|rehti|hain|hun|hoon)\s+'
            r'([a-z][a-z\s]{2,20}?)(?=\s*[,.]|\s*$)',
        ]
        for pat in origin_patterns:
            match = re.search(pat, text, re.IGNORECASE)
            if match:
                candidate = match.group(1).strip().rstrip(".,").lower()
                # Prefer exact city match first, then substring
                for city_lower in sorted(KNOWN_CITIES, key=len, reverse=False):  # shorter first for exact
                    if candidate.strip() == city_lower:
                        return CITY_CANONICAL.get(city_lower, city_lower.title())
                for city_lower in sorted(KNOWN_CITIES, key=len, reverse=True):   # longer first for substr
                    if city_lower in candidate or candidate in city_lower:
                        return CITY_CANONICAL.get(city_lower, city_lower.title())

        # Word-boundary fallback scan
        # Two passes: first exact match, then substring — prevents "navi mumbai" 
        # stealing a match when user just said "mumbai"
        for city_lower in sorted(KNOWN_CITIES, key=len, reverse=True):
            # Only match if city_lower appears as its OWN whole token (not as part of longer city)
            pattern = r'(?<![a-z])' + re.escape(city_lower) + r'(?![a-z])'
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                # Make sure we are not inside a longer known city that already matched
                matched_str = match.group(0).lower()
                is_part_of_longer = any(
                    c != city_lower and city_lower in c and re.search(
                        r'(?<![a-z])' + re.escape(c) + r'(?![a-z])', text, re.IGNORECASE)
                    for c in KNOWN_CITIES
                )
                if not is_part_of_longer:
                    return CITY_CANONICAL.get(city_lower, city_lower.title())
        return None

    def _extract_preferences(self, text: str) -> List[str]:
        preference_map = {
            "adventure":  ["trek", "trekking", "adventure", "hiking", "camping",
                           "rafting", "bungee", "paragliding", "zipline", "rock climbing",
                           "jeep safari", "quad bike", "extreme"],
            "beach":      ["beach", "sea", "ocean", "coastal", "waves", "seaside",
                           "water sports", "scuba", "snorkeling", "samundar"],
            "hills":      ["hills", "mountains", "mountain", "valley", "snow",
                           "snowfall", "cold place", "hill station", "pahad",
                           "pahadi", "altitude", "meadow", "glacier"],
            "history":    ["historical", "fort", "temple", "heritage", "ancient",
                           "history", "monument", "palace", "museum", "ruins",
                           "qila", "mahal", "mandir"],
            "wildlife":   ["wildlife", "safari", "jungle", "forest", "national park",
                           "tiger", "elephant", "bird watching", "van"],
            "relaxation": ["relax", "peaceful", "spa", "calm", "quiet", "chill",
                           "rest", "shanti", "ayurveda", "wellness", "resort",
                           "slow travel", "no rush"],
            "food":       ["food", "cuisine", "eat", "foodie", "street food",
                           "khana", "seafood", "local food", "culinary"],
            "nightlife":  ["party", "nightlife", "clubs", "bar", "pub",
                           "dance", "music scene", "lounge"],
            "offbeat":    ["offbeat", "unexplored", "hidden", "lesser known",
                           "off the beaten", "unknown", "untouched", "remote"],
            "romantic":   ["romantic", "honeymoon", "anniversary", "candle",
                           "couples", "intimate", "love"],
            "spiritual":  ["temple", "spiritual", "pilgrimage", "mandir", "dham",
                           "ashram", "meditation", "yoga", "teerth"],
        }
        found = []
        for pref, keywords in preference_map.items():
            if any(kw in text for kw in keywords):
                found.append(pref)
        return list(set(found))  # deduplicate

    def _extract_bare_number(self, text: str) -> Optional[float]:
        """
        Extract a standalone number from a short reply like '4', 'four', 'char'.
        Only triggers on short messages (< 6 tokens) to avoid false positives.
        """
        tokens = text.strip().split()
        if len(tokens) > 6:
            return None

        # Pure digit
        match = re.fullmatch(r'(\d+)', text.strip())
        if match:
            return float(match.group(1))

        # Word number
        t = text.strip().rstrip(".,!?").lower()
        if t in WORD_NUMBERS:
            return float(WORD_NUMBERS[t])

        # "just X" / "only X" / "sirf X" / "bas X"
        match2 = re.search(r'(?:just|only|sirf|bas|keval)\s+(\d+)', t)
        if match2:
            return float(match2.group(1))

        match3 = re.search(r'(?:just|only|sirf|bas|keval)\s+(' +
                            '|'.join(WORD_NUMBERS.keys()) + r')', t)
        if match3:
            return float(WORD_NUMBERS[match3.group(1).lower()])

        return None
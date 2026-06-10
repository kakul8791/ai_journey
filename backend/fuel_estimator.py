"""
Fuel Estimator & Speed Optimizer
──────────────────────────────────
Physics-based fuel model + a simple gradient-descent optimizer that finds
the speed profile that minimises fuel while respecting road type speed limits.

Model:  fuel_per_km(v) = a/v + b*v²   (aerodynamic drag + idle consumption)
  a = idle_loss_coefficient  (engine running but not moving)
  b = drag_coefficient       (proportional to v²)

Optimal speed dFuel/dv = 0  →  v* = (a / 2b)^(1/3)

For each road segment we clamp v* to [min_speed, speed_limit].
"""

import math
from pathlib import Path
import json

DATA_DIR = Path(__file__).parent.parent / "data"
PLACES_FILE = DATA_DIR / "places_seed.json"


def _load_places():
    if PLACES_FILE.exists():
        with open(PLACES_FILE) as f:
            return {p["id"]: p for p in json.load(f)}
    return {}


# Vehicle profiles: (fuel_efficiency_kmpl at 60kmph, a_coeff, b_coeff, tank_litres, fuel_type)
VEHICLE_PROFILES = {
    "car": {
        "efficiency_kmpl": 15,
        "a": 0.18,
        "b": 0.00004,
        "tank_litres": 50,
        "fuel_price_inr": 103,
        "fuel_type": "Petrol",
        "seats": 5,
    },
    "bike": {
        "efficiency_kmpl": 40,
        "a": 0.06,
        "b": 0.000012,
        "tank_litres": 12,
        "fuel_price_inr": 103,
        "fuel_type": "Petrol",
        "seats": 2,
    },
    "suv": {
        "efficiency_kmpl": 11,
        "a": 0.22,
        "b": 0.000055,
        "tank_litres": 60,
        "fuel_price_inr": 103,
        "fuel_type": "Diesel",
        "seats": 7,
    },
    "bus": {
        "efficiency_kmpl": 0,   # no personal fuel
        "a": 0, "b": 0,
        "tank_litres": 0,
        "fuel_price_inr": 0,
        "fuel_type": "N/A",
        "seats": 40,
    },
    "train": {
        "efficiency_kmpl": 0,
        "a": 0, "b": 0,
        "tank_litres": 0,
        "fuel_price_inr": 0,
        "fuel_type": "N/A",
        "seats": 999,
    },
    "flight": {
        "efficiency_kmpl": 0,
        "a": 0, "b": 0,
        "tank_litres": 0,
        "fuel_price_inr": 0,
        "fuel_type": "N/A",
        "seats": 999,
    },
}

# Road segment types with typical speed limits (kmph)
ROAD_SEGMENTS = [
    {"type": "City roads",        "speed_limit": 50,  "pct": 0.15},
    {"type": "State highway",     "speed_limit": 80,  "pct": 0.30},
    {"type": "National highway",  "speed_limit": 100, "pct": 0.45},
    {"type": "Ghat / hills",      "speed_limit": 40,  "pct": 0.10},
]


class FuelEstimator:

    def __init__(self):
        self.places = _load_places()

    def estimate(self, origin: str, place_id: str, transport: str, num_people: int) -> dict:
        place = self.places.get(place_id, {})
        distance_km = place.get("distance_km", 300)
        vp = VEHICLE_PROFILES.get(transport, VEHICLE_PROFILES["car"])

        # For public transport – return ticket-based cost estimate
        if transport in ("bus", "train", "flight"):
            return self._public_transport_estimate(transport, distance_km, num_people, place)

        # ── Fuel model ─────────────────────────────────────────────────────
        a, b = vp["a"], vp["b"]
        # Optimal speed (physics) – unconstrained
        v_optimal_unconstrained = (a / (2 * b)) ** (1 / 3) if b > 0 else 70

        speed_schedule = []
        total_fuel_litres = 0.0
        total_time_hours = 0.0

        for seg in ROAD_SEGMENTS:
            seg_km = distance_km * seg["pct"]
            v_opt = min(v_optimal_unconstrained, seg["speed_limit"] * 0.9)  # 10% safety margin
            v_opt = max(v_opt, 20)  # never below 20 kmph

            fuel_per_km = a / v_opt + b * v_opt ** 2
            seg_fuel = fuel_per_km * seg_km
            seg_time = seg_km / v_opt

            total_fuel_litres += seg_fuel
            total_time_hours += seg_time

            speed_schedule.append({
                "segment": seg["type"],
                "distance_km": round(seg_km, 1),
                "recommended_speed_kmph": round(v_opt, 1),
                "speed_limit_kmph": seg["speed_limit"],
                "fuel_for_segment_L": round(seg_fuel, 2),
                "time_minutes": round(seg_time * 60, 0),
                "tip": self._speed_tip(v_opt, seg["speed_limit"]),
            })

        # Return journey
        total_fuel_litres *= 2
        total_time_hours *= 2

        fuel_cost = total_fuel_litres * vp["fuel_price_inr"]
        tanks_needed = math.ceil(total_fuel_litres / vp["tank_litres"])

        # Best vs worst fuel scenario
        worst_fuel = total_fuel_litres * 1.25   # aggressive driving
        best_fuel = total_fuel_litres * 0.90    # ideal conditions

        return {
            "transport": transport,
            "distance_km": distance_km,
            "total_distance_with_return_km": distance_km * 2,
            "fuel_type": vp["fuel_type"],
            "recommended_fuel_litres": round(total_fuel_litres, 1),
            "best_case_litres": round(best_fuel, 1),
            "worst_case_litres": round(worst_fuel, 1),
            "fuel_cost_inr": round(fuel_cost),
            "fuel_price_per_litre_inr": vp["fuel_price_inr"],
            "tanks_needed": tanks_needed,
            "estimated_travel_time_hours": round(total_time_hours, 1),
            "speed_schedule": speed_schedule,
            "eco_tips": self._eco_tips(),
            "avg_efficiency_kmpl": round((distance_km * 2) / total_fuel_litres, 1),
        }

    # ── Public Transport ─────────────────────────────────────────────────────

    def _public_transport_estimate(self, transport, distance_km, num_people, place):
        if transport == "bus":
            cost_per_person = distance_km * 0.8   # ₹0.8/km approx state bus
            time_h = distance_km / 55
        elif transport == "train":
            cost_per_person = distance_km * 0.5 + 200  # base + sleeper approx
            time_h = distance_km / 80
        else:  # flight
            cost_per_person = max(2500, distance_km * 4.5)
            time_h = distance_km / 700 + 3   # travel + airport time

        return {
            "transport": transport,
            "distance_km": distance_km,
            "fuel_type": "N/A",
            "ticket_cost_per_person_inr": round(cost_per_person),
            "total_ticket_cost_inr": round(cost_per_person * num_people),
            "estimated_travel_time_hours": round(time_h, 1),
            "speed_schedule": [],
            "note": f"Ticket prices are approximate. Book on MakeMyTrip / IRCTC for exact fares.",
        }

    # ── Helpers ──────────────────────────────────────────────────────────────

    @staticmethod
    def _speed_tip(v, limit):
        ratio = v / limit
        if ratio < 0.7:
            return "Slow zone – maintain steady speed, avoid unnecessary braking"
        elif ratio < 0.85:
            return "Optimal eco-speed – cruise control recommended if available"
        else:
            return "Near speed limit – stay consistent, avoid aggressive acceleration"

    @staticmethod
    def _eco_tips():
        return [
            "Tyre pressure check before departure can improve mileage by 3-4%",
            "Avoid hard braking – anticipate stops and coast to decelerate",
            "Turn off AC on ghat sections; open windows below 80 kmph",
            "Refuel in the morning when fuel is denser (marginally more per litre)",
            "Keep windows up on highways – aerodynamic drag increases fuel use significantly",
        ]
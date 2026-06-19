from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, List
import uvicorn

from recommendation import RecommendationEngine
from fuel_estimator import FuelEstimator
from itinerary import ItineraryPlanner
from nlp_parser import NLPParser

app = FastAPI(title="Journey Planner AI", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize engines once at startup
rec_engine = RecommendationEngine()
fuel_estimator = FuelEstimator()
itinerary_planner = ItineraryPlanner()
nlp_parser = NLPParser()


# ─── Request / Response Models ────────────────────────────────────────────────

class ChatMessage(BaseModel):
    message: str
    session_id: Optional[str] = "default"
    history: Optional[List[dict]] = []

class TripRequest(BaseModel):
    group_type: str          # couple | family | friends
    budget: float            # INR total budget
    days: int
    origin: str              # city name or lat,lng
    max_distance_km: float
    num_people: int
    preferences: Optional[List[str]] = []

class PlaceSelected(BaseModel):
    place_id: str
    origin: str
    transport: str           # car | bike | bus | train | flight
    num_people: int
    budget: float
    days: int
    group_type: str

class FeedbackRequest(BaseModel):
    place_id: str
    rating: int              # 1-5, used to retrain market basket
    group_type: str
    budget_range: str        # low | mid | high


# ─── Endpoints ────────────────────────────────────────────────────────────────

@app.post("/chat")
async def chat_endpoint(msg: ChatMessage):
    """NLP chatbot – extracts trip intent and returns structured params or a clarifying question."""
    result = nlp_parser.process(msg.message, msg.history)
    return result


@app.post("/recommend")
async def recommend(req: TripRequest):
    """Returns 3-4 ML-ranked place recommendations with cost estimates."""
    try:
        places = rec_engine.recommend(
            group_type=req.group_type,
            budget=req.budget,
            days=req.days,
            origin=req.origin,
            max_distance_km=req.max_distance_km,
            num_people=req.num_people,
            preferences=req.preferences,
        )
        return {"recommendations": places}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/fuel")
async def fuel_estimate(req: PlaceSelected):
    """ fuel estimate, speed schedules, and cost."""
    try:
        result = fuel_estimator.estimate(
            origin=req.origin,
            place_id=req.place_id,
            transport=req.transport,
            num_people=req.num_people,
        )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/itinerary")
async def build_itinerary(req: PlaceSelected):
    """Builds a full day-wise itinerary for the selected place."""
    try:
        plan = itinerary_planner.build(
            place_id=req.place_id,
            origin=req.origin,
            transport=req.transport,
            num_people=req.num_people,
            budget=req.budget,
            days=req.days,
            group_type=req.group_type,
        )
        return plan
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/feedback")
async def record_feedback(req: FeedbackRequest):
    """Records user feedback to retrain the market-basket model."""
    rec_engine.record_feedback(
        place_id=req.place_id,
        rating=req.rating,
        group_type=req.group_type,
        budget_range=req.budget_range,
    )
    return {"status": "ok"}


@app.get("/health")
async def health():
    return {"status": "running"}


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True) 
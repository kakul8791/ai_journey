print("🚗 AI Journey Planner 🚗")

trip_type = input("Enter trip type (family/couple/friends): ")
budget = int(input("Enter your budget: "))
distance = int(input("Enter preferred distance in km: "))

destination = ""
speed = ""

# DESTINATION LOGIC

if trip_type == "family":
    
    if budget < 5000:
        destination = "Jaipur"
    else:
        destination = "Shimla"

elif trip_type == "couple":
    
    if budget < 5000:
        destination = "Rishikesh"
    else:
        destination = "Manali"

elif trip_type == "friends":
    
    if budget < 5000:
        destination = "Kasol"
    else:
        destination = "Goa"

# SPEED LOGIC

if distance < 200:
    speed = "50-60 km/h"

elif distance < 500:
    speed = "70-80 km/h"

else:
    speed = "80-90 km/h"

# FUEL ESTIMATE

fuel_cost = distance * 6

# FINAL OUTPUT

print("\n========== JOURNEY PLAN ==========")

print("Recommended Destination:", destination)

print("Suggested Speed:", speed)

print("Estimated Fuel Cost: ₹", fuel_cost)

print("==================================")
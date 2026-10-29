#include <iostream>
#include <vector>
#include <string>
#include <iomanip>
#include <memory>

// ============================================================================
// OOP Principle: ENCAPSULATION & INHERITANCE (Base Class)
// The Ride class encapsulates ride attributes with protected access,
// allowing derived classes to access them while protecting them from external misuse.
// ============================================================================
class Ride {
protected:
    std::string rideID;
    std::string pickupLocation;
    std::string dropoffLocation;
    double distance; // In miles
    double fareAmount;

public:
    // Constructor initializes the core state of a ride
    Ride(std::string id, std::string pickup, std::string dropoff, double dist)
        : rideID(id), pickupLocation(pickup), dropoffLocation(dropoff), distance(dist), fareAmount(0.0) {}

    virtual ~Ride() = default; // Virtual destructor ensures proper cleanup of derived types

    // Polymorphic method: Virtual function enables dynamic dispatch (Polymorphism)
    virtual double fare() {
        // Base rate: $2.00 base + $1.50 per mile
        fareAmount = 2.00 + (distance * 1.50);
        return fareAmount;
    }

    // Displays ride details polymorphically
    virtual void rideDetails() const {
        std::cout << "Ride ID: " << rideID 
                  << " | From: " << pickupLocation 
                  << " -> To: " << dropoffLocation 
                  << " | Distance: " << distance << " mi"
                  << " | Fare: $" << std::fixed << std::setprecision(2) << fareAmount 
                  << std::endl;
    }

    std::string getRideID() const { return rideID; }
};

// ============================================================================
// OOP Principle: INHERITANCE & POLYMORPHISM (Derived Class 1)
// StandardRide inherits core properties and overrides fare() for standard pricing.
// ============================================================================
class StandardRide : public Ride {
public:
    StandardRide(std::string id, std::string pickup, std::string dropoff, double dist)
        : Ride(id, pickup, dropoff, dist) {}

    // Overriding the fare() method specifically for Standard rides
    double fare() override {
        // Standard rate: $2.50 base pickup fee + $1.75 per mile
        fareAmount = 2.50 + (distance * 1.75);
        return fareAmount;
    }

    void rideDetails() const override {
        std::cout << "[STANDARD RIDE] ";
        Ride::rideDetails();
    }
};

// ============================================================================
// OOP Principle: INHERITANCE & POLYMORPHISM (Derived Class 2)
// PremiumRide inherits core properties and overrides fare() for luxury pricing.
// ============================================================================
class PremiumRide : public Ride {
private:
    double luxurySurcharge;

public:
    PremiumRide(std::string id, std::string pickup, std::string dropoff, double dist, double surcharge = 5.00)
        : Ride(id, pickup, dropoff, dist), luxurySurcharge(surcharge) {}

    // Overriding the fare() method with higher mileage rate and luxury surcharge
    double fare() override {
        // Premium rate: $5.00 base + $3.25 per mile + luxury surcharge
        fareAmount = 5.00 + (distance * 3.25) + luxurySurcharge;
        return fareAmount;
    }

    void rideDetails() const override {
        std::cout << "[PREMIUM RIDE]  ";
        Ride::rideDetails();
    }
};

// ============================================================================
// OOP Principle: ENCAPSULATION
// Driver class encapsulates assignedRides in a private member variable.
// It can only be accessed or modified via addRide() and getDriverInfo().
// ============================================================================
class Driver {
private:
    std::string driverID;
    std::string name;
    double rating;
    std::vector<std::shared_ptr<Ride>> assignedRides; // Encapsulated private list

public:
    Driver(std::string id, std::string driverName, double driverRating)
        : driverID(id), name(driverName), rating(driverRating) {}

    // Controlled mutation through public method
    void addRide(std::shared_ptr<Ride> ride) {
        assignedRides.push_back(ride);
    }

    // Controlled read access through public method
    void getDriverInfo() const {
        std::cout << "\n================ DRIVER PROFILE ================\n"
                  << "Driver ID: " << driverID << "\n"
                  << "Name: " << name << "\n"
                  << "Rating: " << rating << " / 5.0\n"
                  << "Completed Rides Count: " << assignedRides.size() << "\n"
                  << "Completed Rides Details:\n";
        for (const auto& ride : assignedRides) {
            std::cout << "  - ";
            ride->rideDetails();
        }
        std::cout << "================================================\n";
    }
};

// ============================================================================
// OOP Principle: ENCAPSULATION
// Rider class encapsulates requestedRides in a private member variable.
// ============================================================================
class Rider {
private:
    std::string riderID;
    std::string name;
    std::vector<std::shared_ptr<Ride>> requestedRides; // Encapsulated private list

public:
    Rider(std::string id, std::string riderName)
        : riderID(id), name(riderName) {}

    // Add ride request
    void requestRide(std::shared_ptr<Ride> ride) {
        // Compute fare dynamically at request time
        ride->fare();
        requestedRides.push_back(ride);
    }

    // Controlled display of ride history
    void viewRides() const {
        std::cout << "\n================ RIDER HISTORY ================\n"
                  << "Rider ID: " << riderID << "\n"
                  << "Name: " << name << "\n"
                  << "Total Requested Rides: " << requestedRides.size() << "\n";
        for (const auto& ride : requestedRides) {
            std::cout << "  * ";
            ride->rideDetails();
        }
        std::cout << "===============================================\n";
    }
};

// ============================================================================
// SYSTEM DEMONSTRATION & POLYMORPHISM IN ACTION
// ============================================================================
int main() {
    std::cout << "--------------------------------------------------\n";
    std::cout << "   RIDE SHARING SYSTEM DEMONSTRATION (C++)\n";
    std::cout << "--------------------------------------------------\n\n";

    // Create heterogeneous rides managed polymorphically via base class pointers
    std::vector<std::shared_ptr<Ride>> fleet;
    fleet.push_back(std::make_shared<StandardRide>("SR-101", "Downtown", "Airport", 14.5));
    fleet.push_back(std::make_shared<PremiumRide>("PR-202", "Financial District", "Uptown", 8.2));
    fleet.push_back(std::make_shared<StandardRide>("SR-103", "Metro Station", "Suburbs", 22.0));
    fleet.push_back(std::make_shared<PremiumRide>("PR-204", "Grand Hotel", "Convention Center", 5.0));

    // DEMONSTRATING POLYMORPHISM:
    // Iterating through a collection of Ride pointers and calling overridden methods dynamically.
    std::cout << "--- POLYMORPHIC FARE CALCULATION & DETAILS ---\n";
    for (const auto& ride : fleet) {
        ride->fare();        // Dynamic dispatch routes to StandardRide or PremiumRide implementation
        ride->rideDetails(); // Dynamic dispatch prints appropriate ride badge & details
    }

    // DEMONSTRATING ENCAPSULATION WITH RIDER & DRIVER:
    Rider rider1("R-501", "Alice Johnson");
    rider1.requestRide(fleet[0]);
    rider1.requestRide(fleet[1]);
    rider1.viewRides();

    Driver driver1("D-901", "Bob Smith", 4.92);
    driver1.addRide(fleet[0]);
    driver1.addRide(fleet[1]);
    driver1.getDriverInfo();

    return 0;
}
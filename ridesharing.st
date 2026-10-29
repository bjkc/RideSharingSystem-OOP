"============================================================================
 Safe Number Formatter to prevent macOS GNU Smalltalk Float printString bug
============================================================================"
Object subclass: NumberFormatter [
    NumberFormatter class >> format: aNumber decimals: places [
        | factor totalInt whole frac fracStr factorInt |
        factor := 1.
        1 to: places do: [ :i | factor := factor * 10 ].
        totalInt := (aNumber * factor) rounded.
        whole := totalInt // factor.
        frac := (totalInt \\ factor) abs.
        fracStr := frac printString.
        [ fracStr size < places ] whileTrue: [ fracStr := '0', fracStr ].
        ^ (whole printString), '.', fracStr
    ]
]

"============================================================================
 OOP Principle: ENCAPSULATION & INHERITANCE (Base Class: Ride)
 All instance variables are private by default in Smalltalk.
============================================================================"
Object subclass: Ride [
    | rideID pickupLocation dropoffLocation distance fareAmount |

    Ride class >> id: anId from: aPickup to: aDropoff distance: aDist [
        | instance |
        instance := self new.
        instance initId: anId from: aPickup to: aDropoff distance: aDist.
        ^ instance
    ]

    initId: anId from: aPickup to: aDropoff distance: aDist [
        rideID := anId.
        pickupLocation := aPickup.
        dropoffLocation := aDropoff.
        distance := aDist.
        fareAmount := 0.
    ]

    fare [
        fareAmount := 2.0 + (distance * 1.5).
        ^ fareAmount
    ]

    rideDetails [
        | distStr fareStr |
        distStr := NumberFormatter format: distance decimals: 2.
        fareStr := NumberFormatter format: fareAmount decimals: 2.
        Transcript show: 'Ride ID: ', rideID, 
                        ' | From: ', pickupLocation, 
                        ' -> To: ', dropoffLocation, 
                        ' | Distance: ', distStr, ' mi',
                        ' | Fare: $', fareStr; cr.
    ]

    getRideID [
        ^ rideID
    ]
]

"============================================================================
 OOP Principle: INHERITANCE & POLYMORPHISM (Derived Class: StandardRide)
 StandardRide inherits from Ride and overrides fare calculation.
============================================================================"
Ride subclass: StandardRide [
    fare [
        fareAmount := 2.5 + (distance * 1.75).
        ^ fareAmount
    ]

    rideDetails [
        Transcript show: '[STANDARD RIDE] '.
        super rideDetails.
    ]
]

"============================================================================
 OOP Principle: INHERITANCE & POLYMORPHISM (Derived Class: PremiumRide)
 PremiumRide inherits from Ride, adds luxury surcharge, and overrides fare.
============================================================================"
Ride subclass: PremiumRide [
    | luxurySurcharge |

    PremiumRide class >> id: anId from: aPickup to: aDropoff distance: aDist surcharge: aSurcharge [
        | instance |
        instance := self new.
        instance initId: anId from: aPickup to: aDropoff distance: aDist.
        instance initSurcharge: aSurcharge.
        ^ instance
    ]

    initSurcharge: aSurcharge [
        luxurySurcharge := aSurcharge.
    ]

    fare [
        (luxurySurcharge isNil) ifTrue: [ luxurySurcharge := 5.0 ].
        fareAmount := 5.0 + (distance * 3.25) + luxurySurcharge.
        ^ fareAmount
    ]

    rideDetails [
        Transcript show: '[PREMIUM RIDE]  '.
        super rideDetails.
    ]
]

"============================================================================
 OOP Principle: ENCAPSULATION (Driver Class)
 assignedRides is an internal OrderedCollection, strictly encapsulated.
============================================================================"
Object subclass: Driver [
    | driverID name rating assignedRides |

    Driver class >> id: anId name: aName rating: aRating [
        | instance |
        instance := self new.
        instance initId: anId name: aName rating: aRating.
        ^ instance
    ]

    initId: anId name: aName rating: aRating [
        driverID := anId.
        name := aName.
        rating := aRating.
        assignedRides := OrderedCollection new.
    ]

    addRide: aRide [
        assignedRides add: aRide.
    ]

    getDriverInfo [
        | ratingStr |
        ratingStr := NumberFormatter format: rating decimals: 2.
        Transcript cr; show: '================ DRIVER PROFILE ================'; cr.
        Transcript show: 'Driver ID: ', driverID; cr.
        Transcript show: 'Name: ', name; cr.
        Transcript show: 'Rating: ', ratingStr, ' / 5.0'; cr.
        Transcript show: 'Completed Rides Count: ', (assignedRides size printString); cr.
        Transcript show: 'Completed Rides Details:'; cr.
        assignedRides do: [ :eachRide |
            Transcript show: '  - '.
            eachRide rideDetails.
        ].
        Transcript show: '================================================'; cr.
    ]
]

"============================================================================
 OOP Principle: ENCAPSULATION (Rider Class)
 requestedRides is maintained internally and accessed only via methods.
============================================================================"
Object subclass: Rider [
    | riderID name requestedRides |

    Rider class >> id: anId name: aName [
        | instance |
        instance := self new.
        instance initId: anId name: aName.
        ^ instance
    ]

    initId: anId name: aName [
        riderID := anId.
        name := aName.
        requestedRides := OrderedCollection new.
    ]

    requestRide: aRide [
        aRide fare.
        requestedRides add: aRide.
    ]

    viewRides [
        Transcript cr; show: '================ RIDER HISTORY ================'; cr.
        Transcript show: 'Rider ID: ', riderID; cr.
        Transcript show: 'Name: ', name; cr.
        Transcript show: 'Total Requested Rides: ', (requestedRides size printString); cr.
        requestedRides do: [ :eachRide |
            Transcript show: '  * '.
            eachRide rideDetails.
        ].
        Transcript show: '==============================================='; cr.
    ]
]

"============================================================================
 SYSTEM EXECUTION & POLYMORPHISM IN ACTION
============================================================================"
| fleet standard1 premium1 standard2 premium2 rider1 driver1 |

Transcript show: '--------------------------------------------------'; cr.
Transcript show: '   RIDE SHARING SYSTEM DEMONSTRATION (Smalltalk)'; cr.
Transcript show: '--------------------------------------------------'; cr; cr.

"Instantiate rides"
standard1 := StandardRide id: 'SR-101' from: 'Downtown' to: 'Airport' distance: 14.5.
premium1  := PremiumRide id: 'PR-202' from: 'Financial District' to: 'Uptown' distance: 8.2 surcharge: 5.0.
standard2 := StandardRide id: 'SR-103' from: 'Metro Station' to: 'Suburbs' distance: 22.0.
premium2  := PremiumRide id: 'PR-204' from: 'Grand Hotel' to: 'Convention Center' distance: 5.0 surcharge: 5.0.

"Polymorphic collection"
fleet := OrderedCollection new.
fleet add: standard1; add: premium1; add: standard2; add: premium2.

Transcript show: '--- POLYMORPHIC FARE CALCULATION & DETAILS ---'; cr.
fleet do: [ :ride |
    ride fare.
    ride rideDetails.
].

"Encapsulation demonstration"
rider1 := Rider id: 'R-501' name: 'Alice Johnson'.
rider1 requestRide: standard1.
rider1 requestRide: premium1.
rider1 viewRides.

driver1 := Driver id: 'D-901' name: 'Bob Smith' rating: 4.92.
driver1 addRide: standard1.
driver1 addRide: premium1.
driver1 getDriverInfo.
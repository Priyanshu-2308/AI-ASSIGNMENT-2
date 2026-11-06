# Mars Rover Planning Assignment Report


## Domain and problem design

In Domain.pddl, we modelled the Mars rover domain using five types: rover, location, sample, bay, and drill. We created five actions: move, pick-drill, collect-soft, collect-hard, and deposit. We split sample collection into collect-soft and collect-hard because of tool requirements. Collecting a soft rock only requires the rover to be at the location with an empty bay. Collecting a hard rock requires an empty bay and also requires the rover to carry the drill. In Problem.pddl and Problem_extended.pddl, two-way routes between sites are encoded by specifying two connected facts, one in each direction. The one-way route between SiteC and SiteD is encoded by including only (connected sitec sited) and leaving out the opposite direction. In Problem_extended.pddl, a dust storm blocks the path between Base and SiteB. We modelled this block by removing the two facts (connected base siteb) and (connected siteb base).

## Planner results

Plan length and total actions are the same number because every action costs 1.
The action sequences are in the .plan files.

| Configuration | Plan length | Total actions | States expanded | Planning time |
| --- | --- | --- | --- | --- |
| Standard Satisficing (lazy_greedy([ff()])) | 33 | 33 | 120 | 0.18s |
| Standard Optimal (astar(lmcut())) | 25 | 25 | 5807 | 0.65s |
| Extended Satisficing (lazy_greedy([ff()])) | 46 | 46 | 240 | 0.17s |
| Extended Optimal (astar(lmcut())) | 40 | 40 | 2230074 | 199.00s |

## Task 6 answers

1. In the standard scenario, the satisficing plan takes 33 steps while the optimal plan takes 25 steps, saving 8 steps. The satisficing plan makes 5 return trips to Base and only ever uses Bay1, carrying one rock at a time (rock1, rock4, rock2, rock3, rock5) and returning after each one. The optimal plan makes 3 return trips to Base and fills both bays on two of its trips, carrying rock2 in Bay1 and rock4 in Bay2 on trip 1, and rock5 in Bay1 and rock3 in Bay2 on trip 2. In the extended scenario, the satisficing plan takes 46 steps with 5 trips to Base, while the optimal plan takes 40 steps with 4 trips to Base. Both plans use both bays. In extended_satisficing.plan, the rover pairs rock2 and rock4 on trip 3 and pairs rock5 and rock7 on trip 4, but it carries three rocks alone on separate trips (rock1 on trip 1, rock3 on trip 2, and rock6 on trip 5). In extended_optimal.plan, the rover pairs six rocks across three trips: rock4 with rock2 on trip 1, rock5 with rock7 on trip 2, and rock3 with rock6 on trip 3, leaving only rock1 carried alone on trip 4. Pairing rock3 and rock6 saves an entire trip to Base and explains the 6 step difference. For search effort, the satisficing configuration expanded 120 states for the standard scenario and 240 states for the extended scenario, while the optimal configuration expanded 5807 states for the standard scenario and 2230074 states taking 199.00s (199 s) for the extended scenario.

2. In standard_optimal.plan, the rover uses both bays to bring back two rocks per trip on two of its trips. On trip 1, it collects soft rock2 into Bay1 at step 2, moves to SiteD, and collects soft rock4 into Bay2 at step 4, sharing the trip. At step 12, the rover picks up the drill at SiteE using (pick-drill curiosity drill1 sitee). After picking up the drill, it moves to SiteF and collects hard rock5 into Bay1 at step 14 using the drill. It then moves to SiteC and collects hard rock3 into Bay2 at step 17 using the drill. The hard rocks are collected in the order of rock5 at SiteF first, followed by rock3 at SiteC second. On trip 3, the rover collects soft rock1 into Bay1 and returns to Base.

3. In the extended scenario, SiteB only connects to Base and SiteD, so once the Base-SiteB road is closed by the dust storm, SiteB can only be reached through SiteD. SiteD can be reached from SiteC using the one-way route, or from SiteE. Going Base, SiteA, SiteC, SiteD takes one move from SiteC, while going through SiteE takes two moves from SiteC, so both plans use the one-way route from SiteC to SiteD. In extended_satisficing.plan, the rover uses the one-way route at step 16 to reach SiteD, then moves to SiteB at step 17. In extended_optimal.plan, the rover uses the one-way route at step 3 to reach SiteD, collects rock4 at step 4, and moves to SiteB at step 5. Because the rover cannot return from SiteD to SiteC and cannot return from SiteB to Base, it must return from SiteB through SiteD and SiteE. In extended_satisficing.plan, the rover returns by moving SiteB to SiteD at step 19, collects rock4 at step 20, moves SiteD to SiteE at step 21, and returns to Base via SiteC and SiteA. In extended_optimal.plan, the rover returns by moving SiteB to SiteD at step 7, SiteD to SiteE at step 8, picks up the drill at SiteE at step 9, and returns to Base via SiteC and SiteA.

## Goal verification

We verified all four plans using our own simulator, verify_plan.py, and saved the complete output in verification_output.txt. VAL was not installed on our system, so it was not run. The output shows that all action preconditions are met at every step. In all four plans, every rock ends at Base, both bays are empty, and the rover is at Base.

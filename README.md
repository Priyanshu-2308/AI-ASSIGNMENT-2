# Group Assignment 2 – Problem 2: Mars Rover Sample Collection Planning (PDDL)

**Team Name:** The Boys

## Group Members

| Name | Roll Number |
| --- | --- |
| Siddhesh Bansal | B24DS030 |
| Shivam Yadav | B24CS040 |
| Shubham Kumar Jha | B24DS029 |
| Rajnish | B24DS024 |
| Priyanshu Priyadarshi | B24CS036 |

## Overview

The Mars rover *Curiosity* (two storage bays, one drill) collects soft and hard rock samples from sites A–F and delivers them to Base. The domain is modelled in PDDL using only the `:strips` and `:typing` requirements. Plans are generated with Fast Downward using two search configurations and verified with our own step-by-step simulator.

## Repository Structure

```
.
├── README.md
├── Domain.pddl                  # Task 1: types, predicates, actions
├── Problem.pddl                 # Task 2: standard scenario (Rock1–Rock5)
├── Problem_extended.pddl        # Task 5: extended scenario (Rock1–Rock7, Base<->SiteB closed)
├── planner_output/              # Task 3: planner logs and plans
│   ├── standard_satisficing.log / .plan
│   ├── standard_optimal.log / .plan
│   ├── extended_satisficing.log / .plan
│   └── extended_optimal.log / .plan
├── verify_plan.py               # Task 4: plan simulator / goal verifier
├── verification_output.txt      # Task 4: full verifier output with final states
├── analysis_report.md           # Task 6: analysis report
└── screenshots/                 # Screenshots of outputs
```

## Planner Configurations

| Scenario | Configuration | Plan length | Total actions | States expanded | Planning time |
| --- | --- | --- | --- | --- | --- |
| Standard | Satisficing: `lazy_greedy([ff()])` | 33 | 33 | 120 | 0.18 s |
| Standard | Optimal: `astar(lmcut())` | 25 | 25 | 5807 | 0.65 s |
| Extended | Satisficing: `lazy_greedy([ff()])` | 46 | 46 | 240 | 0.17 s |
| Extended | Optimal: `astar(lmcut())` | 40 | 40 | 2,230,074 | 199.00 s |

Every action has unit cost, so plan length equals the total number of actions.

## How to Run

Generate a plan (Fast Downward):

```bash
# Satisficing
fast-downward.py Domain.pddl Problem.pddl --search "lazy_greedy([ff()])"

# Optimal
fast-downward.py Domain.pddl Problem.pddl --search "astar(lmcut())"
```

Use `Problem_extended.pddl` in place of `Problem.pddl` for the extended scenario.

Verify all four plans (run from the folder that contains the PDDL files and the `.plan` files):

```bash
python3 verify_plan.py
```

To verify a single plan:

```bash
python3 verify_plan.py Problem.pddl standard_optimal.plan
```

The simulator checks the preconditions at every step, prints the added and removed facts, and prints the final state. VAL is also run automatically if it is installed (it was not installed on our system).

## Result

For all four plans the verifier confirms that every rock is at Base, both bays are empty, and the rover is at Base. See `verification_output.txt` and the `screenshots/` folder.

## Notes

- The one-way route SiteC → SiteD is encoded by including only `(connected sitec sited)`.
- In the extended scenario the dust storm is modelled by removing both `(connected base siteb)` and `(connected siteb base)`.
- The full discussion of plan lengths, bay usage, drill pickup and the one-way route is in `analysis_report.md`.

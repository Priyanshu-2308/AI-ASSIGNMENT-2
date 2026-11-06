Files in this folder:
- Domain.pddl: PDDL domain definition for Mars rover actions and predicates.
- Problem.pddl: Standard scenario problem definition with 5 rocks.
- Problem_extended.pddl: Extended scenario problem definition with 7 rocks and dust storm.
- standard_satisficing.plan / .log: Plan and run log for standard satisficing search.
- standard_optimal.plan / .log: Plan and run log for standard optimal search.
- extended_satisficing.plan / .log: Plan and run log for extended satisficing search.
- extended_optimal.plan / .log: Plan and run log for extended optimal search.
- verify_plan.py: Python script that simulates and verifies plans step by step.
- verification_output.txt: Verification output log for all four plans.
- analysis_report.md: Report with problem design, results table, and analysis answers.
- README.txt: Description of files and execution commands.

Fast Downward commands:
The translator reads Domain.pddl and the problem file (Problem.pddl or Problem_extended.pddl) to produce output.sas.
The search commands from the logs are:

1. Standard satisficing:
/home/rajnish/pddl_ai/downward/builds/release/bin/downward --search 'lazy_greedy([ff()])' --internal-plan-file result/standard_satisficing.plan < output.sas

2. Standard optimal:
/home/rajnish/pddl_ai/downward/builds/release/bin/downward --search 'astar(lmcut())' --internal-plan-file result/standard_optimal.plan < output.sas

3. Extended satisficing:
/home/rajnish/pddl_ai/downward/builds/release/bin/downward --search 'lazy_greedy([ff()])' --internal-plan-file result/extended_satisficing.plan < output.sas

4. Extended optimal:
/home/rajnish/pddl_ai/downward/builds/release/bin/downward --search 'astar(lmcut())' --internal-plan-file result/extended_optimal.plan < output.sas

Verification commands:
python3 verify_plan.py
python3 verify_plan.py <problem file> <plan file>


import sys
import os
import re
import shutil
import subprocess

# strip pddl comments
def strip_comments(text):
    lines = [line.split(';')[0] for line in text.splitlines()]
    return '\n'.join(lines)

# find balanced block like (:init or (:goal
def find_block(text, header):
    idx = text.find(header)
    if idx == -1:
        return ''
    open_count = 0
    for i in range(idx, len(text)):
        if text[i] == '(':
            open_count += 1
        elif text[i] == ')':
            open_count -= 1
            if open_count == 0:
                return text[idx:i+1]
    return ''

# extract atomic facts from block
def extract_facts(block_text):
    facts = []
    for m in re.finditer(r'\(\s*([a-zA-Z0-9_-]+(?:\s+[a-zA-Z0-9_-]+)*)\s*\)', block_text):
        tokens = tuple(m.group(1).strip().lower().split())
        if tokens and tokens[0] not in (':init', ':goal', 'and'):
            facts.append(tokens)
    return set(facts)

# load initial state and goal facts
def parse_problem(problem_path):
    with open(problem_path, 'r') as f:
        clean = strip_comments(f.read())
    init_facts = extract_facts(find_block(clean, '(:init'))
    goal_facts = extract_facts(find_block(clean, '(:goal'))
    return init_facts, goal_facts

# read action lines from plan file
def parse_plan(plan_path):
    actions = []
    with open(plan_path, 'r') as f:
        for line in f:
            clean = line.split(';')[0].strip()
            if clean.startswith('(') and clean.endswith(')'):
                tokens = clean[1:-1].strip().lower().split()
                if tokens:
                    actions.append(tokens)
    return actions

def format_fact(fact):
    return '(' + ' '.join(fact) + ')'

# simulate a plan on a problem
def verify(problem_path, plan_path):
    out = []
    out.append('=' * 60)
    out.append(f'Verifying plan: {plan_path}')
    out.append(f'Problem file:   {problem_path}')
    out.append('=' * 60)

    init_facts, goal_facts = parse_problem(problem_path)
    actions = parse_plan(plan_path)
    state = set(init_facts)

    # find rocks, rovers, and bays
    rocks = set(fact[1] for fact in init_facts if fact[0] in ('soft', 'hard', 'at-sample'))
    rocks = sorted(list(rocks), key=lambda x: int(re.search(r'\d+', x).group()) if re.search(r'\d+', x) else x)
    rovers = sorted(list(set(fact[1] for fact in init_facts if fact[0] == 'at')))
    bays = sorted(list(set(fact[1] for fact in init_facts if fact[0] == 'bay-empty')))

    success = True
    for step_num, act in enumerate(actions, 1):
        action_name = act[0]
        args = act[1:]
        act_str = f'({action_name} ' + ' '.join(args) + ')'

        preconds = []
        adds = []
        dels = []

        # actions matching Domain.pddl
        if action_name == 'move':
            r, f, t = args
            preconds = [('at', r, f), ('connected', f, t)]
            adds = [('at', r, t)]
            dels = [('at', r, f)]
        elif action_name == 'pick-drill':
            r, d, l = args
            preconds = [('at', r, l), ('at-drill', d, l)]
            adds = [('has-drill', r, d)]
            dels = [('at-drill', d, l)]
        elif action_name == 'collect-soft':
            r, s, l, b = args
            preconds = [('at', r, l), ('at-sample', s, l), ('bay-empty', b), ('soft', s)]
            adds = [('in-bay', s, b)]
            dels = [('bay-empty', b), ('at-sample', s, l)]
        elif action_name == 'collect-hard':
            r, s, l, b, d = args
            preconds = [('at', r, l), ('at-sample', s, l), ('bay-empty', b), ('hard', s), ('has-drill', r, d)]
            adds = [('in-bay', s, b)]
            dels = [('bay-empty', b), ('at-sample', s, l)]
        elif action_name == 'deposit':
            r, s, b, l = args
            preconds = [('at', r, l), ('in-bay', s, b)]
            adds = [('at-sample', s, l), ('bay-empty', b)]
            dels = [('in-bay', s, b)]
        else:
            out.append(f'Step {step_num}: Unknown action {action_name}')
            success = False
            break

        # check preconditions
        failed_preconds = [p for p in preconds if p not in state]
        if failed_preconds:
            out.append(f'Step {step_num}: {act_str}')
            out.append(f'FAILED PRECONDITION: {format_fact(failed_preconds[0])}')
            out.append('Action could not be executed. Stopping simulation.')
            success = False
            break

        # update state
        for d in dels:
            state.discard(d)
        for a in adds:
            state.add(a)

        added_str = ', '.join(format_fact(a) for a in adds) if adds else 'none'
        removed_str = ', '.join(format_fact(d) for d in dels) if dels else 'none'
        out.append(f'Step {step_num}: {act_str}')
        out.append(f'  Added:   {added_str}')
        out.append(f'  Removed: {removed_str}')

    out.append('-' * 60)
    out.append('Final state:')
    for r in rovers:
        r_loc = [fact[2] for fact in state if fact[0] == 'at' and fact[1] == r]
        loc_str = r_loc[0] if r_loc else 'unknown'
        out.append(f'Rover {r} is at: {loc_str}')

    all_bays_empty = True
    for b in bays:
        is_empty = ('bay-empty', b) in state
        if not is_empty:
            all_bays_empty = False
        in_b = [fact[1] for fact in state if fact[0] == 'in-bay' and fact[2] == b]
        item_str = f'holding {in_b[0]}' if in_b else 'empty'
        out.append(f'Bay {b}: {item_str}')
    out.append(f'Both bays are empty: {all_bays_empty}')

    out.append('Rock locations:')
    for s in rocks:
        loc = [fact[2] for fact in state if fact[0] == 'at-sample' and fact[1] == s]
        bay = [fact[2] for fact in state if fact[0] == 'in-bay' and fact[1] == s]
        if loc:
            out.append(f'  {s}: at {loc[0]}')
        elif bay:
            out.append(f'  {s}: in {bay[0]}')
        else:
            out.append(f'  {s}: unknown')

    missing_goals = [g for g in goal_facts if g not in state]
    if success and not missing_goals:
        out.append('Goal satisfied: True')
    else:
        out.append('Goal satisfied: False')
        if missing_goals:
            out.append('Missing goal facts: ' + ', '.join(format_fact(g) for g in missing_goals))

    out.append('')
    return '\n'.join(out)

def run_all():
    # select Problem.pddl or problem.pddl
    if os.path.exists('Problem.pddl'):
        std_prob = 'Problem.pddl'
    elif os.path.exists('problem.pddl'):
        std_prob = 'problem.pddl'
    else:
        std_prob = 'Problem.pddl'

    if os.path.exists('Problem_extended.pddl'):
        ext_prob = 'Problem_extended.pddl'
    elif os.path.exists('problem_extended.pddl'):
        ext_prob = 'problem_extended.pddl'
    else:
        ext_prob = 'Problem_extended.pddl'

    domain_file = 'Domain.pddl' if os.path.exists('Domain.pddl') else 'domain.pddl'

    runs = [
        (std_prob, 'standard_satisficing.plan'),
        (std_prob, 'standard_optimal.plan'),
        (ext_prob, 'extended_satisficing.plan'),
        (ext_prob, 'extended_optimal.plan'),
    ]

    all_output = []
    for prob, plan in runs:
        res = verify(prob, plan)
        all_output.append(res)

    # run VAL if installed
    val_cmd = shutil.which('validate') or shutil.which('val')
    if val_cmd:
        all_output.append('=' * 60)
        all_output.append('VAL Plan Validator Output:')
        all_output.append('=' * 60)
        for prob, plan in runs:
            try:
                val_res = subprocess.run([val_cmd, domain_file, prob, plan], capture_output=True, text=True)
                all_output.append(f'VAL {prob} {plan}:')
                all_output.append(val_res.stdout)
            except Exception as e:
                all_output.append(f'Error running VAL on {plan}: {e}')

    combined = '\n'.join(all_output)
    with open('verification_output.txt', 'w') as f:
        f.write(combined)
    print(combined)

if __name__ == '__main__':
    if len(sys.argv) == 3:
        output = verify(sys.argv[1], sys.argv[2])
        print(output)
    else:
        run_all()

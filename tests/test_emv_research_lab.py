import unittest
from ui.emv_research_lab import PROFILES, SCENARIOS, campaign, level5_plan, run_one

class EMVResearchLabTests(unittest.TestCase):
    def test_all_declared_combinations_admit(self):
        for p in PROFILES:
            for s in SCENARIOS:
                r=run_one(p,s)
                self.assertTrue(r['admitted'], (p['profile_id'],s['id'],r['admission_reason']))

    def test_replay_deterministic(self):
        a=campaign(repetitions=2); b=campaign(repetitions=2)
        self.assertEqual(a['campaign_hash'],b['campaign_hash'])
        self.assertEqual(a['deterministic_replay'],True)
        self.assertTrue(a['projection_idempotence'])

    def test_level5_plan_is_machine_computable(self):
        p=level5_plan(repetitions=3)
        self.assertEqual(p['level'],5)
        self.assertEqual(p['dimensions']['planned_primary_executions'],len(PROFILES)*len(SCENARIOS)*3)

    def test_status_word_mutation_rejects(self):
        s=next(x for x in SCENARIOS if x['id']=='SCN-005')
        for p in PROFILES:
            self.assertFalse(run_one(p,s)['acceptance']['accepted'])

    def test_timing_is_quotient_residual(self):
        p=PROFILES[0]
        a=run_one(p,next(x for x in SCENARIOS if x['id']=='SCN-002'))
        b=run_one(p,next(x for x in SCENARIOS if x['id']=='SCN-003'))
        self.assertEqual(a['quotient_class'],b['quotient_class'])

if __name__=='__main__': unittest.main()

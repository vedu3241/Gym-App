const express = require("express");
const memberController = require("./controllers/memberController");
const membershipController = require("./controllers/membershipController");
const router = express.Router();

router.post("/addMember", memberController().addMember);
router.get("/getMembers", memberController().getAllMembers);
router.get("/removeMember", memberController().removeMember);
router.post("/updateMemberDue", memberController().updateMemberDue);

router.post("/updateMembership", memberController().updateMembership);
router.get("/getIncome", memberController().getIncomeValues);
router.get("/getAvailIncomeYears", memberController().AvailIncomeYears);

//Membership plan
router.post("/newPlan", membershipController().addNewPlan);
router.get("/plans", membershipController().getPlans);
router.put("/updatePlans", membershipController().updateMultiplePlans);
// router.post("/updatePlan", membershipController().updatePlan);
router.post("/deletePlan", membershipController().deletePlan);

//Memberships
router.get("/activeMemberships", membershipController().getActiveMemberships);
router.get("/membershipHistory", membershipController().getMembershipHistory);
router.get(
  "/recent-membership",
  membershipController().getMostRecentMembership
);

module.exports = router;

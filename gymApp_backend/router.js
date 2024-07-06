const express = require("express");
const memberController = require("./controllers/memberController");
const router = express.Router();

router.post("/addMember", memberController().addMember);
router.get("/getMembers", memberController().getAllMembers);
router.post("/updateMembership", memberController().updateMembership);
router.get("/removeMember", memberController().removeMember);
router.post("/updateMemberDue", memberController().updateMemberDue);
router.get("/getIncome", memberController().getIncomeValues);
router.get("/getAvailIncomeYears", memberController().AvailIncomeYears);

module.exports = router;

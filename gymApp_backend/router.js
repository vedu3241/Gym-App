const express = require("express");
const memberController = require("./controllers/memberController");
const router = express.Router();

router.post("/addMember", memberController().addMember);
router.get("/getMembers", memberController().getAllMembers);
router.post("/updateMembership", memberController().updateMembership);

module.exports = router;

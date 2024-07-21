const mongoose = require("mongoose");
const Schema = mongoose.Schema;

// Define the MembershipPlan schema
const membershipPlanSchema = new Schema({
  months: { type: Number, required: true },
  price: { type: Number, required: true },
});

// Create a model based on the schema
const MembershipPlan = mongoose.model("MembershipPlan", membershipPlanSchema);

module.exports = MembershipPlan;

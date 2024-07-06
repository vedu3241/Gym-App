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

////////////////////////////////////////////////

const mongoose = require("mongoose");
const MembershipPlan = require("./models/membershipPlan"); // Replace with your actual path

// Connect to MongoDB
mongoose
  .connect("mongodb://localhost:27017/gymDatabase", {
    useNewUrlParser: true,
    useUnifiedTopology: true,
  })
  .then(() => {
    console.log("Connected to MongoDB");

    // Example: Create a new membership plan
    const newPlan = new MembershipPlan({ months: 1, price: 600 });
    newPlan
      .save()
      .then(() => {
        console.log("New membership plan saved");
      })
      .catch((err) => {
        console.error("Error saving membership plan", err);
      });

    // Example: Find all membership plans
    MembershipPlan.find()
      .then((plans) => {
        console.log("All membership plans:", plans);
      })
      .catch((err) => {
        console.error("Error fetching membership plans", err);
      });

    // Example: Update a membership plan
    MembershipPlan.updateOne({ months: 1 }, { price: 700 })
      .then(() => {
        console.log("Membership plan updated");
      })
      .catch((err) => {
        console.error("Error updating membership plan", err);
      });

    // Example: Delete a membership plan
    MembershipPlan.deleteOne({ months: 1 })
      .then(() => {
        console.log("Membership plan deleted");
      })
      .catch((err) => {
        console.error("Error deleting membership plan", err);
      });
  })
  .catch((err) => {
    console.error("Error connecting to MongoDB", err);
  });

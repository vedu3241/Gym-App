const mongoose = require("mongoose");
const MembershipPlan = require("../models/planPrice_model");
const Membership = require("../models/Membership_model");
function membershipController() {
  return {
    async addNewPlan(req, res) {
      console.log(req.body);
      const { months, price } = req.body;

      const newPlan = new MembershipPlan({ months: months, price: price });
      newPlan
        .save()
        .then(() => {
          console.log("New membership plan saved");
          res.status(200).send("New plan added");
        })
        .catch((err) => {
          console.error("Error saving membership plan", err);
        });
    },
    // fetch plans
    async getPlans(req, res) {
      try {
        var data = await MembershipPlan.find({});
        if (data && data.length > 0) {
          // console.log(data);
          res.status(200).json({ plans: data });
        }
      } catch (err) {
        console.log(err);
      }
    },
    async updatePlan(req, res) {
      const { id, newMonths, newPrice } = req.body;
      const filter = { _id: id };
      const update = { months: newMonths, price: newPrice };

      await MembershipPlan.updateOne(filter, update)
        .then(() => {
          res.status(200).send("Membership updated");
        })
        .catch((err) => {
          console.error("Error updating membership plan", err);
        });
    },

    // PLAN BULK UPDATE
    async updateMultiplePlans(req, res) {
      const updates = req.body;

      // Check if updates is an array
      if (!Array.isArray(updates)) {
        return res.status(400).json({ error: "Request body must be an array" });
      }

      // Map updates to bulk operations
      const bulkOps = updates.map((update) => ({
        updateOne: {
          filter: { _id: update.id },
          update: { price: update.price },
        },
      }));

      try {
        await MembershipPlan.bulkWrite(bulkOps);
        res.status(200).json({ message: "Plans updated successfully" });
      } catch (error) {
        console.error("Error updating plans:", error);
        res.status(500).json({ error: "Failed to update plans" });
      }
    },
    //delete plan
    async deletePlan(req, res) {
      try {
        const id = req.body.id;
        await MembershipPlan.deleteOne({ _id: id })
          .then(() => {
            res.status(200);
          })
          .catch((err) => {
            console.error("Error deleting membership plan", err);
          });
      } catch (err) {
        console.log(err);
      }
    },

    async getActiveMemberships(req, res) {
      try {
        const data = await Membership.find({});
        if (data) {
          // Filter memberships where the virtual field 'expired' is false
          const activeMemberships = data.filter(
            (membership) => !membership.expired
          );
          res.status(200).json({ activeMemberships: activeMemberships });
        }
      } catch (err) {
        console.log(err);
      }
    },

    async getMembershipHistory(req, res) {
      try {
        const id = req.query.memberId;
        const data = await Membership.find({ memberId: id }).sort({
          planStartDate: -1,
        });
        res.status(200).json({ history: data });
      } catch (err) {
        console.log(err);
      }
    },

    async getMostRecentMembership(req, res) {
      const memberId = req.query.memberId;
      console.log(memberId);
      try {
        // Sort by start date in descending order
        await Membership.findOne({ memberId })
          .sort({ planStartDate: -1 })
          .then((mostRecentMembership) => {
            if (!mostRecentMembership) {
              return res
                .status(404)
                .json({ message: "No memberships found for this member." });
            }
            res.status(200).json({ recentMembership: mostRecentMembership });
          })
          .catch((error) => {
            res.status(500).json({ message: error.message });
          });
      } catch (error) {
        console.error("Error fetching recent membership:", error);
        throw error;
      }
    },
  };
}
module.exports = membershipController;

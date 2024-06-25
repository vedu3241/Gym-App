const { Timestamp } = require("bson");
const mongoose = require("mongoose");
const Schema = mongoose.Schema;

// Helper function to calculate the planExpiryDate
const calculatePlanExpiryDate = (startDate, membershipPeriod) => {
  return new Date(
    startDate.getFullYear(),
    startDate.getMonth() + membershipPeriod,
    startDate.getDate()
  );
};

const calculateDueAmount = (actualAmount, paidAmount) => {
  const dueAmount = actualAmount - paidAmount;
  return dueAmount;
};

const memberSchema = new Schema(
  {
    first_name: String,
    last_name: String,
    phone_num: Number,
    gender: String,
    medicalIssue: String,
    membership_Period: Number,
    profile_img: String,
    actual_amount: Number,
    paid_amount: Number,
    due_amount: {
      type: Number,
      default: function () {
        return calculateDueAmount(this.actual_amount, this.paid_amount);
      },
    },
    planStartDate: {
      type: Date,
      default: Date.now,
    },
    planExpiryDate: {
      type: Date,
      default: function () {
        return calculatePlanExpiryDate(
          this.planStartDate,
          this.membership_Period
        );
      },
    },
  },
  { timestamps: true }
);

// Virtual for daysRemaining
memberSchema.virtual("daysRemaining").get(function () {
  const today = new Date();
  const expiryDate = this.planExpiryDate;
  const timeDiff = expiryDate.getTime() - today.getTime();
  return Math.ceil(timeDiff / (1000 * 3600 * 24));
});

// Virtual for expired
memberSchema.virtual("expired").get(function () {
  return this.daysRemaining <= 0;
});

// Ensure virtual fields are serialized
memberSchema.set("toJSON", { virtuals: true });
memberSchema.set("toObject", { virtuals: true });

const Member = mongoose.model("Member", memberSchema);

module.exports = Member;

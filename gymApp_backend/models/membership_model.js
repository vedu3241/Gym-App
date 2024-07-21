const mongoose = require("mongoose");
const Schema = mongoose.Schema;

// Returns Due amount
const calculateDueAmount = (membershipAmount, paidAmount) => {
  const dueAmount = membershipAmount - paidAmount;
  return dueAmount;
};

// Helper function to get current date in IST
const getCurrentDateIST = () => {
  const currentDate = new Date();
  return new Date(currentDate.getTime() + 5.5 * 60 * 60 * 1000);
};

// Helper function to calculate the planExpiryDate in IST
const calculatePlanExpiryDate = (startDate, membershipPeriod) => {
  let date = new Date(
    startDate.getFullYear(),
    startDate.getMonth() + membershipPeriod,
    startDate.getDate()
  );

  // Convert to IST
  date = new Date(date.getTime() + 5.5 * 60 * 60 * 1000);
  return date;
};

const membershipSchema = new Schema(
  {
    memberId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Member",
      required: true,
    },
    membershipAmount: Number,
    paidAmount: Number,
    dueAmount: {
      type: Number,
      default: function () {
        return calculateDueAmount(this.membershipAmount, this.paidAmount);
      },
    },
    membership_Period: Number,
    planStartDate: {
      type: Date,
      default: getCurrentDateIST,
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
membershipSchema.virtual("daysRemaining").get(function () {
  const today = new Date();
  const expiryDate = this.planExpiryDate;
  const timeDiff = expiryDate.getTime() - today.getTime();
  return Math.ceil(timeDiff / (1000 * 3600 * 24));
});

// Virtual for expired
membershipSchema.virtual("expired").get(function () {
  return this.daysRemaining <= 0;
});

// Ensure virtual fields are serialized
membershipSchema.set("toJSON", { virtuals: true });
membershipSchema.set("toObject", { virtuals: true });

const Membership = mongoose.model("Membership", membershipSchema);

module.exports = Membership;

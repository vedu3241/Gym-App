const { Timestamp } = require("bson");
const mongoose = require("mongoose");
const Schema = mongoose.Schema;

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

const calculateDueAmount = (actualAmount, paidAmount) => {
  const dueAmount = actualAmount - paidAmount;
  return dueAmount;
};

// Helper function to get current date in IST
const getCurrentDateIST = () => {
  const currentDate = new Date();
  return new Date(currentDate.getTime() + 5.5 * 60 * 60 * 1000);
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

// Pre-save middleware to adjust dates to IST
memberSchema.pre("save", function (next) {
  if (this.isModified("planStartDate")) {
    this.planStartDate = new Date(
      this.planStartDate.getTime() + 5.5 * 60 * 60 * 1000
    );
  }
  if (this.isModified("planExpiryDate")) {
    this.planExpiryDate = new Date(
      this.planExpiryDate.getTime() + 5.5 * 60 * 60 * 1000
    );
  }
  next();
});

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

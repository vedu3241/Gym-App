const { json } = require("body-parser");
const Member = require("../models/member_model");
const IncomeHistory = require("../models/incomeHistory_model");
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
//helper function to upadteIncome history
async function updateIncome(paidAmount = 0, paidDue = 0) {
  try {
    const now = new Date();
    const monthNames = [
      "jan",
      "feb",
      "mar",
      "apr",
      "may",
      "jun",
      "jul",
      "aug",
      "sep",
      "oct",
      "nov",
      "dec",
    ];
    const currentMonth = monthNames[now.getMonth()];
    const currentYear = now.getFullYear();

    // Convert paidAmount and paidDue to integers explicitly
    const newIncome = parseInt(paidAmount, 10) + parseInt(paidDue, 10);

    const data = await IncomeHistory.findOne({ year: currentYear });
    if (data) {
      const currentIncome = parseInt(data[currentMonth], 10); // current income for that month
      const finalIncome = currentIncome + newIncome;
      const filter = { year: currentYear };
      const update = { [currentMonth]: finalIncome };
      await IncomeHistory.findOneAndUpdate(filter, update);
      console.log("Income updated ");
    } else {
      const incomeHistory = new IncomeHistory({
        year: currentYear,
        [currentMonth]: newIncome,
      });

      await incomeHistory.save().then(() => {
        console.log("Income inserted");
      });
    }
  } catch (err) {
    console.log(err);
  }
}

// const Complaint = require("../../models/complaints");
function memberController() {
  return {
    async addMember(req, res) {
      const {
        fname,
        lname,
        phoneNum,
        gender,
        medicalIssue,
        membershipPeriod,
        actual_amount,
        paid_amount,
      } = req.body;

      if (
        !fname ||
        !lname ||
        !phoneNum ||
        !gender ||
        !medicalIssue ||
        !membershipPeriod ||
        !actual_amount ||
        !paid_amount
      ) {
        return res
          .status(422)
          .json({ message: "ServerError: Fields cannot be empty" });
      }
      if (!req.files || !req.files.profileImage) {
        return res.status(400).send("ServerError: Profile Img not uploaded.");
      }
      console.log("passed img check!");
      try {
        const uploadedImg = req.files.profileImage;
        const filePath =
          __dirname + "/../public/profile_img/" + uploadedImg.name;
        const imageName = uploadedImg.name; // for storing into MongoDB
        // Moving file to local storage
        uploadedImg.mv(filePath, (err) => {
          if (err) {
            console.log(err);
            return res.status(500).send(err);
          }
          updateIncome(parseInt(paid_amount));
          const newMember = new Member({
            first_name: fname,
            last_name: lname,
            phone_num: phoneNum,
            gender: gender,
            medicalIssue: medicalIssue,
            membership_Period: membershipPeriod,
            profile_img: imageName,
            actual_amount: actual_amount,
            paid_amount: paid_amount,
          });

          newMember
            .save()
            .then(() => {
              console.log("Member Inserted");
              return res.status(200).json({ message: "Member added.." });
            })
            .catch((err) => {
              console.log(`Error: adding member ${err}`);
              return res.status(500).json({
                message: "An error occurred while adding new member",
              });
            });
        });
      } catch (err) {
        console.log(err);
      }
    },

    async getAllMembers(req, res) {
      const data = await Member.find({});
      if (data && data.length > 0) {
        // data.reverse();
        // console.log(data);
        console.log("GET members hit");
        res.status(200).json({ members: data });
      } else {
        console.log("No members found");
        return res
          .status(401)
          .json({ message: "ServerError: No members found" });
      }
    },
    async updateMembership(req, res) {
      const {
        id,
        membershipPeriod,
        actualAmount,
        paidAmount,
        dueAmount,
        paidDueAmount,
      } = req.body;
      try {
        const currentDate = new Date();

        //Updating income
        updateIncome(parseInt(paidAmount), parseInt(paidDueAmount));

        const currentDue = actualAmount - paidAmount;
        const pastDue = dueAmount - paidDueAmount;

        const totalDue = currentDue + pastDue;
        //Calculating Plan start date
        const planStartDate = new Date(
          currentDate.getTime() + 5.5 * 60 * 60 * 1000
        );
        // Calculating expiry date
        const expiryDate = calculatePlanExpiryDate(
          planStartDate,
          membershipPeriod
        );

        const filter = { _id: id };
        const update = {
          membership_Period: membershipPeriod,
          actual_amount: actualAmount,
          paid_amount: paidAmount,
          due_amount: totalDue,
          planStartDate: planStartDate,
          planExpiryDate: expiryDate,
        };

        result = await Member.updateOne(filter, update);
        if (result.modifiedCount > 0) {
          console.log("Modified");
          return res.status(200).json({
            message: "Membership updated successfully",
          });
        } else {
          return res.status(404).json({
            message: "Member not found or no updates applied",
          });
        }
      } catch (err) {
        console.log("Error in :updateMem - " + err);
      }

      // console.log(req.body);
    },

    async removeMember(req, res) {
      const memberId = req.query.memberId;
      if (memberId) {
        console.log(`Member ID: ${memberId}`);
        try {
          Member.deleteOne({ _id: memberId })
            .then(() => {
              console.log("member deleted");
              res.status(200).send(`Member ID ${memberId} removed`);
            })
            .catch((err) => {
              console.log("error deleting member in catch");
            });
        } catch (err) {
          console.log("Something went wrong.." + err);
        }
      } else {
        res.status(400).send("Member ID not found");
      }
    },

    async updateMemberDue(req, res) {
      try {
        const { paidDue, due, memberId } = req.body;

        //UPDATING INCOME
        updateIncome(parseInt(paidDue));
        remainingDue = due - paidDue;
        const filter = { _id: memberId };
        const update = { due_amount: remainingDue };

        result = await Member.updateOne(filter, update);
        if (result.modifiedCount > 0) {
          console.log("Due updated");
          return res.status(200).json({
            message: "Due updated successfully",
          });
        } else {
          return res.status(404).json({
            message: "Member not found or no updates applied",
          });
        }
      } catch (err) {
        console.log(err);
      }
    },
    async getIncomeValues(req, res) {
      //fetch the income history as per year
      selectedYear = req.query.year;
      // console.log("selected year :" + selectedYear);
      data = await IncomeHistory.findOne({ year: selectedYear }); //2024 as for now later will pass users choice

      // Extract _doc from originalObject
      const { _doc } = data;
      const { _id, year, __v, ...remainingValues } = _doc;
      // console.log(remainingValues);

      res.status(200).json({ data: remainingValues });
    },
    //to fetch income history years available
    async AvailIncomeYears(req, res) {
      try {
        const uniqueYears = await IncomeHistory.distinct("year");
        console.log("Avail years: " + uniqueYears);
        res.status(200).json({ years: uniqueYears });
      } catch (error) {
        console.error("Error fetching unique years:", error);
        throw error;
      }
    },
  };
}

module.exports = memberController;

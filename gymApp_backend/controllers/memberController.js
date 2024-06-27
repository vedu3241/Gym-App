const Member = require("../models/member_model");
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
          due_amount: currentDue + pastDue,
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
  };
}

module.exports = memberController;

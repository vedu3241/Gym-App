const Member = require("../models/member_model");

// const Complaint = require("../../models/complaints");
function memberController() {
  return {
    async addMember(req, res) {
      const { fname, lname, phoneNum, gender, medicalIssue, membershipPeriod } =
        req.body;

      if (
        !fname ||
        !lname ||
        !phoneNum ||
        !gender ||
        !medicalIssue ||
        !membershipPeriod
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
        const filePath = __dirname + "/../profile_images/" + uploadedImg.name;
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
          });

          newMember
            .save()
            .then(() => {
              console.log("Member Inserted");
              return res.status(201).json({ message: "Member added.." });
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
  };
}

module.exports = memberController;

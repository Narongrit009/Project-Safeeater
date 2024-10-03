import React from "react";
import Swal from "sweetalert2";
import axios from "axios";

const DiseaseAdd = ({ onAdd }) => {
  // Handle the form submission
  const handleAddDisease = async (name, description) => {
    if (!name) {
      Swal.fire("ข้อผิดพลาด", "กรุณากรอกชื่อโรค", "error");
      return;
    }

    try {
      // Call API to add a new disease
      const response = await axios.post(
        `${import.meta.env.VITE_API_URL_GET_DISEASES}`,
        {
          condition_name: name,
          condition_description: description,
        },
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      if (response.data.status === "success") {
        Swal.fire("สำเร็จ", "เพิ่มโรคเรียบร้อยแล้ว", "success").then(() => {
          // Close the popup and refresh the list
          onAdd();
        });
      } else {
        Swal.fire("ข้อผิดพลาด", "ไม่สามารถเพิ่มโรคได้", "error");
      }
    } catch (error) {
      Swal.fire("ข้อผิดพลาด", "เกิดข้อผิดพลาดขณะเพิ่มโรค", "error");
    }
  };

  // Display the form in a popup using SweetAlert2
  const showAddDiseasePopup = () => {
    Swal.fire({
      title: "<h2 class='text-lg font-semibold'>เพิ่มโรคใหม่</h2>",
      html: `
        <div class="flex flex-col gap-4">
          <input id="disease-name" class="swal2-input px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="ชื่อโรค" />
          <textarea id="disease-description" class="swal2-textarea px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="รายละเอียดโรค"></textarea>
        </div>
      `,
      showCancelButton: true,
      confirmButtonColor: "#4CAF50",
      cancelButtonColor: "#d33",
      confirmButtonText: "เพิ่ม",
      cancelButtonText: "ยกเลิก",
      preConfirm: () => {
        const name = Swal.getPopup().querySelector("#disease-name").value;
        const description = Swal.getPopup().querySelector(
          "#disease-description"
        ).value;
        if (!name) {
          Swal.showValidationMessage("กรุณากรอกชื่อโรค");
        }
        return { name: name, description: description };
      },
    }).then((result) => {
      if (result.isConfirmed) {
        handleAddDisease(result.value.name, result.value.description);
      }
    });
  };

  return (
    <button
      onClick={showAddDiseasePopup}
      className="bg-gradient-to-r from-green-400 to-green-600 text-white px-6 py-2 rounded-full hover:from-green-500 hover:to-green-700 transition duration-300 shadow-lg hover:shadow-xl transform hover:scale-105"
    >
      + เพิ่มโรค
    </button>
  );
};

export default DiseaseAdd;

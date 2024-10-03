import React from "react";
import Swal from "sweetalert2";
import axios from "axios";

const DiseaseEdit = ({ disease, onEdit }) => {
  // Handle the form submission for editing the disease
  const handleEditDisease = async (updatedDisease) => {
    if (!updatedDisease.name) {
      Swal.fire("ข้อผิดพลาด", "กรุณากรอกชื่อโรค", "error");
      return;
    }

    try {
      // Call API to edit the disease
      const response = await axios.put(
        `${import.meta.env.VITE_API_URL_GET_DISEASES}`,
        {
          condition_id: disease.condition_id,
          condition_name: updatedDisease.name,
          condition_description: updatedDisease.description,
        },
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      if (response.data.status === "success") {
        Swal.fire("สำเร็จ", "แก้ไขโรคเรียบร้อยแล้ว", "success").then(() => {
          // Refresh the list
          onEdit();
        });
      } else {
        Swal.fire("ข้อผิดพลาด", "ไม่สามารถแก้ไขโรคได้", "error");
      }
    } catch (error) {
      Swal.fire("ข้อผิดพลาด", "เกิดข้อผิดพลาดขณะทำการแก้ไขโรค", "error");
    }
  };

  // Display the form in a popup using SweetAlert2
  const showEditDiseasePopup = () => {
    Swal.fire({
      title: "<h2 class='text-lg font-semibold'>แก้ไขโรค</h2>",
      html: `
        <div class="flex flex-col gap-4">
          <input id="disease-name" class="swal2-input px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="ชื่อโรค" value="${disease.condition_name}" />
          <textarea id="disease-description" class="swal2-textarea px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="รายละเอียดโรค">${disease.condition_description}</textarea>
        </div>
      `,
      showCancelButton: true,
      confirmButtonColor: "#4CAF50",
      cancelButtonColor: "#d33",
      confirmButtonText: "บันทึก",
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
        handleEditDisease(result.value);
      }
    });
  };

  return (
    <button
      onClick={showEditDiseasePopup}
      className="bg-yellow-400 hover:bg-yellow-500 text-white px-3 py-1 rounded-full shadow-md hover:shadow-lg transition duration-300 transform hover:scale-105"
    >
      แก้ไข
    </button>
  );
};

export default DiseaseEdit;

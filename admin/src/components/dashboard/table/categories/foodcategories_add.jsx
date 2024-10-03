import React from "react";
import Swal from "sweetalert2";
import axios from "axios";

const FoodCategoriesAdd = ({ onAdd }) => {
  // ฟังก์ชันจัดการการเพิ่มหมวดหมู่ใหม่
  const handleAddCategory = async (name, description) => {
    if (!name) {
      Swal.fire("ข้อผิดพลาด", "กรุณาระบุชื่อหมวดหมู่", "error");
      return;
    }

    try {
      // เรียกใช้ API เพื่อเพิ่มหมวดหมู่ใหม่
      const response = await axios.post(
        `${import.meta.env.VITE_API_URL_GET_FOOD_CATEGORIES}`,
        {
          category_name: name,
          description: description,
        },
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      if (response.data.status === "success") {
        Swal.fire("สำเร็จ", "เพิ่มหมวดหมู่เรียบร้อยแล้ว", "success").then(
          () => {
            // รีเฟรชรายการหลังจากเพิ่มข้อมูล
            onAdd();
          }
        );
      } else {
        Swal.fire(
          "ข้อผิดพลาด",
          response.data.message || "ไม่สามารถเพิ่มหมวดหมู่ได้",
          "error"
        );
      }
    } catch (error) {
      Swal.fire("ข้อผิดพลาด", "เกิดข้อผิดพลาดขณะเพิ่มหมวดหมู่", "error");
    }
  };

  // แสดงฟอร์มในป๊อปอัพด้วย SweetAlert2
  const showAddCategoryPopup = () => {
    Swal.fire({
      title: "<h2 class='text-lg font-semibold'>เพิ่มหมวดหมู่ใหม่</h2>",
      html: `
        <div class="flex flex-col gap-4">
          <input id="category-name" class="swal2-input px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="ชื่อหมวดหมู่" />
          <textarea id="category-description" class="swal2-textarea px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="รายละเอียดหมวดหมู่"></textarea>
        </div>
      `,
      showCancelButton: true,
      confirmButtonColor: "#4CAF50",
      cancelButtonColor: "#d33",
      confirmButtonText: "เพิ่ม",
      cancelButtonText: "ยกเลิก",
      preConfirm: () => {
        const name = Swal.getPopup().querySelector("#category-name").value;
        const description = Swal.getPopup().querySelector(
          "#category-description"
        ).value;
        if (!name) {
          Swal.showValidationMessage("กรุณาระบุชื่อหมวดหมู่");
        }
        return { name, description };
      },
    }).then((result) => {
      if (result.isConfirmed) {
        handleAddCategory(result.value.name, result.value.description);
      }
    });
  };

  return (
    <button
      onClick={showAddCategoryPopup}
      className="bg-gradient-to-r from-green-400 to-green-600 text-white px-6 py-2 rounded-full hover:from-green-500 hover:to-green-700 transition duration-300 shadow-lg hover:shadow-xl transform hover:scale-105"
    >
      + เพิ่มหมวดหมู่
    </button>
  );
};

export default FoodCategoriesAdd;

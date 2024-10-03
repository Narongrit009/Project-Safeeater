import React from "react";
import Swal from "sweetalert2";
import axios from "axios";

const FoodCategoriesEdit = ({ category, onEdit }) => {
  // ฟังก์ชันจัดการการแก้ไขหมวดหมู่
  const handleEditCategory = async (id, name, description) => {
    if (!name) {
      Swal.fire("ข้อผิดพลาด", "กรุณาระบุชื่อหมวดหมู่", "error");
      return;
    }

    try {
      // เรียกใช้ API เพื่อแก้ไขหมวดหมู่
      const response = await axios.put(
        `${import.meta.env.VITE_API_URL_GET_FOOD_CATEGORIES}`,
        {
          id: id,
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
        Swal.fire("สำเร็จ", "แก้ไขหมวดหมู่เรียบร้อยแล้ว", "success").then(
          () => {
            // รีเฟรชรายการในคอมโพเนนต์หลัก
            onEdit();
          }
        );
      } else {
        Swal.fire(
          "ข้อผิดพลาด",
          response.data.message || "ไม่สามารถแก้ไขหมวดหมู่ได้",
          "error"
        );
      }
    } catch (error) {
      Swal.fire("ข้อผิดพลาด", "เกิดข้อผิดพลาดขณะทำการแก้ไขหมวดหมู่", "error");
    }
  };

  // แสดงแบบฟอร์มแก้ไขในป๊อปอัพด้วย SweetAlert2
  const showEditCategoryPopup = () => {
    Swal.fire({
      title: "<h2 class='text-lg font-semibold'>แก้ไขหมวดหมู่</h2>",
      html: `
        <div class="flex flex-col gap-4">
          <input id="category-name" class="swal2-input px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="ชื่อหมวดหมู่" value="${category.category_name}" />
          <textarea id="category-description" class="swal2-textarea px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="รายละเอียดหมวดหมู่">${category.description}</textarea>
        </div>
      `,
      showCancelButton: true,
      confirmButtonColor: "#4CAF50",
      cancelButtonColor: "#d33",
      confirmButtonText: "บันทึก",
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
        handleEditCategory(
          category.id,
          result.value.name,
          result.value.description
        );
      }
    });
  };

  return (
    <button
      onClick={showEditCategoryPopup}
      className="bg-yellow-400 hover:bg-yellow-500 text-white px-3 py-1 rounded-full shadow-md hover:shadow-lg transition duration-300 transform hover:scale-105"
    >
      แก้ไข
    </button>
  );
};

export default FoodCategoriesEdit;

import React, { useState } from "react";
import Swal from "sweetalert2";
import axios from "axios";

const IngredientAdd = ({ onAdd }) => {
  const [ingredientData, setIngredientData] = useState({
    ingredient_name: "",
    calories: "",
    quantity_per_unit: "",
    protein: "",
    fat: "",
    carbohydrates: "",
    dietary_fiber: "",
    calcium: "",
    iron: "",
    vitamin_c: "",
    sodium: "",
    sugar: "",
    cholesterol: "",
    image_url: "",
  });

  // Handle form submission
  const handleAddIngredient = async (data) => {
    try {
      // Call API to add a new ingredient
      const response = await axios.post(
        `${import.meta.env.VITE_API_URL_GET_INGREDIENTS}`,
        data,
        {
          headers: {
            "Content-Type": "application/json",
          },
        }
      );

      if (response.data.status === "success") {
        Swal.fire("สำเร็จ", "เพิ่มส่วนผสมเรียบร้อยแล้ว", "success").then(() => {
          // Clear form fields
          setIngredientData({
            ingredient_name: "",
            calories: "",
            quantity_per_unit: "",
            protein: "",
            fat: "",
            carbohydrates: "",
            dietary_fiber: "",
            calcium: "",
            iron: "",
            vitamin_c: "",
            sodium: "",
            sugar: "",
            cholesterol: "",
            image_url: "",
          });
          // Refresh the list
          onAdd();
        });
      } else {
        Swal.fire("ข้อผิดพลาด", "การเพิ่มส่วนผสมล้มเหลว", "error");
      }
    } catch (error) {
      Swal.fire("ข้อผิดพลาด", "เกิดข้อผิดพลาดในการเพิ่มส่วนผสม", "error");
    }
  };

  // Display the form in a popup using SweetAlert2
  const showAddIngredientPopup = () => {
    Swal.fire({
      title:
        "<h2 class='text-2xl font-semibold mb-6 text-blue-600'>เพิ่มวัตถุดิบใหม่</h2>",
      html: `
        <div class="flex flex-col items-center gap-6">
          <div class="flex flex-wrap gap-6 justify-center">
            <div class="w-full sm:w-1/3">
              <input id="ingredient_name" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="ชื่อวัตถุดิบ"/>
            </div>
            <div class="w-full sm:w-1/3">
              <input id="image_url" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="URL รูปภาพ (ใช้ภาพจาก flaticon.com)"/>
              <small class="block text-gray-500 mt-1 text-sm">ใช้ภาพจาก <a href="https://www.flaticon.com/" target="_blank" class="text-blue-500 underline">flaticon.com</a></small>
            </div>
          </div>
          <div class="w-full grid grid-cols-2 sm:grid-cols-3 gap-4">
            <input id="calories" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="แคลอรี่ (kcal)"/>
            <input id="quantity_per_unit" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="ปริมาณ (กรัม)"/>
            <input id="protein" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="โปรตีน (กรัม)"/>
            <input id="fat" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="ไขมัน (กรัม)"/>
            <input id="carbohydrates" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="คาร์โบไฮเดรต (กรัม)"/>
            <input id="dietary_fiber" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="ใยอาหาร (กรัม)"/>
            <input id="calcium" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="แคลเซียม (มก.)"/>
            <input id="iron" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="เหล็ก (มก.)"/>
            <input id="vitamin_c" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="วิตามิน C (มก.)"/>
            <input id="sodium" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="โซเดียม (มก.)"/>
            <input id="sugar" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="น้ำตาล (กรัม)"/>
            <input id="cholesterol" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="คอเลสเตอรอล (มก.)"/>
          </div>
        </div>
      `,
      showCancelButton: true,
      confirmButtonColor: "#1D4ED8",
      cancelButtonColor: "#d33",
      confirmButtonText: "เพิ่ม",
      cancelButtonText: "ยกเลิก",
      customClass: {
        popup: "p-8 rounded-xl w-full max-w-3xl",
      },
      preConfirm: () => {
        // Collect input values
        const ingredient_name =
          Swal.getPopup().querySelector("#ingredient_name").value;
        const calories = Swal.getPopup().querySelector("#calories").value;
        const quantity_per_unit =
          Swal.getPopup().querySelector("#quantity_per_unit").value;
        const protein = Swal.getPopup().querySelector("#protein").value;
        const fat = Swal.getPopup().querySelector("#fat").value;
        const carbohydrates =
          Swal.getPopup().querySelector("#carbohydrates").value;
        const dietary_fiber =
          Swal.getPopup().querySelector("#dietary_fiber").value;
        const calcium = Swal.getPopup().querySelector("#calcium").value;
        const iron = Swal.getPopup().querySelector("#iron").value;
        const vitamin_c = Swal.getPopup().querySelector("#vitamin_c").value;
        const sodium = Swal.getPopup().querySelector("#sodium").value;
        const sugar = Swal.getPopup().querySelector("#sugar").value;
        const cholesterol = Swal.getPopup().querySelector("#cholesterol").value;
        const image_url = Swal.getPopup().querySelector("#image_url").value;

        // Validation
        if (!ingredient_name) {
          Swal.showValidationMessage("กรุณากรอกชื่อส่วนผสม");
          return false; // Prevent submission if name is empty
        }

        // Return validated data
        return {
          ingredient_name,
          calories,
          quantity_per_unit,
          protein,
          fat,
          carbohydrates,
          dietary_fiber,
          calcium,
          iron,
          vitamin_c,
          sodium,
          sugar,
          cholesterol,
          image_url,
        };
      },
    }).then((result) => {
      if (result.isConfirmed) {
        // Set data and call handleAddIngredient
        handleAddIngredient(result.value);
      }
    });
  };

  return (
    <button
      onClick={showAddIngredientPopup}
      className="bg-gradient-to-r from-green-400 to-green-600 text-white px-6 py-2 rounded-full hover:from-green-500 hover:to-green-700 transition duration-300 shadow-lg hover:shadow-xl transform hover:scale-105"
    >
      + เพิ่มวัตถุดิบ
    </button>
  );
};

export default IngredientAdd;

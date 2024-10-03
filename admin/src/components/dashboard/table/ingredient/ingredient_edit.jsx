import React, { useState } from "react";
import Swal from "sweetalert2";
import axios from "axios";

const IngredientEdit = ({ ingredient, onEdit }) => {
  const [ingredientData, setIngredientData] = useState(ingredient);

  // Handle the form submission
  const handleEditIngredient = async (updatedData) => {
    try {
      // ใช้ URL ที่ถูกต้องในการแก้ไขข้อมูล
      const response = await axios.put(
        `${import.meta.env.VITE_API_URL_GET_INGREDIENTS}/${
          updatedData.ingredient_id
        }`,
        updatedData, // ส่งข้อมูลที่อัปเดตไปยัง API
        {
          headers: {
            "Content-Type": "application/json", // กำหนดชนิดข้อมูลเป็น JSON
          },
        }
      );

      if (response.data.status === "success") {
        Swal.fire("Success", "Ingredient updated successfully", "success").then(
          () => {
            onEdit(); // รีเฟรชข้อมูลเมื่อแก้ไขสำเร็จ
          }
        );
      } else {
        Swal.fire("Error", "Failed to update ingredient", "error");
      }
    } catch (error) {
      Swal.fire(
        "Error",
        "An error occurred while updating the ingredient",
        "error"
      );
    }
  };

  // Display the form in a popup using SweetAlert2
  const showEditIngredientPopup = () => {
    Swal.fire({
      title: `<h2 class='text-2xl font-semibold mb-6 text-blue-600'>Edit Ingredient</h2>`,
      html: `
          <div class="flex flex-col items-center gap-6">
            <!-- Horizontal Section for Ingredient Name and Image URL -->
            <div class="flex flex-wrap gap-6 justify-center w-full">
              <div class="w-full sm:w-1/2 mb-4">
                <label for="ingredient_name" class="block text-sm font-medium text-gray-700 mb-1">Ingredient Name</label>
                <input id="ingredient_name" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Ingredient Name" value="${ingredientData.ingredient_name}" />
              </div>
              <div class="w-full sm:w-1/2 mb-4">
                <label for="image_url" class="block text-sm font-medium text-gray-700 mb-1">Image URL</label>
                <input id="image_url" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Image URL" value="${ingredientData.image_url}" />
                <small class="block text-gray-500 mt-1 text-sm">Use images from <a href="https://www.flaticon.com/" target="_blank" class="text-blue-500 underline">flaticon.com</a></small>
              </div>
            </div>
      
            <!-- Nutrition Details Grid -->
            <div class="w-full grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
              <div>
                <label for="calories" class="block text-sm font-medium text-gray-700 mb-1">Calories (kcal)</label>
                <input id="calories" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Calories" value="${ingredientData.calories}" />
              </div>
              <div>
                <label for="quantity_per_unit" class="block text-sm font-medium text-gray-700 mb-1">Quantity (g)</label>
                <input id="quantity_per_unit" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Quantity" value="${ingredientData.quantity_per_unit}" />
              </div>
              <div>
                <label for="protein" class="block text-sm font-medium text-gray-700 mb-1">Protein (g)</label>
                <input id="protein" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Protein" value="${ingredientData.protien}" />
              </div>
              <div>
                <label for="fat" class="block text-sm font-medium text-gray-700 mb-1">Fat (g)</label>
                <input id="fat" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Fat" value="${ingredientData.fat}" />
              </div>
              <div>
                <label for="carbohydrates" class="block text-sm font-medium text-gray-700 mb-1">Carbohydrates (g)</label>
                <input id="carbohydrates" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Carbohydrates" value="${ingredientData.carbohydrates}" />
              </div>
              <div>
                <label for="dietary_fiber" class="block text-sm font-medium text-gray-700 mb-1">Dietary Fiber (g)</label>
                <input id="dietary_fiber" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Dietary Fiber" value="${ingredientData.dietary_fiber}" />
              </div>
              <div>
                <label for="calcium" class="block text-sm font-medium text-gray-700 mb-1">Calcium (mg)</label>
                <input id="calcium" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Calcium" value="${ingredientData.calcium}" />
              </div>
              <div>
                <label for="iron" class="block text-sm font-medium text-gray-700 mb-1">Iron (mg)</label>
                <input id="iron" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Iron" value="${ingredientData.iron}" />
              </div>
              <div>
                <label for="vitamin_c" class="block text-sm font-medium text-gray-700 mb-1">Vitamin C (mg)</label>
                <input id="vitamin_c" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Vitamin C" value="${ingredientData.vitamin_c}" />
              </div>
              <div>
                <label for="sodium" class="block text-sm font-medium text-gray-700 mb-1">Sodium (mg)</label>
                <input id="sodium" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Sodium" value="${ingredientData.sodium}" />
              </div>
              <div>
                <label for="sugar" class="block text-sm font-medium text-gray-700 mb-1">Sugar (g)</label>
                <input id="sugar" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Sugar" value="${ingredientData.sugar}" />
              </div>
              <div>
                <label for="cholesterol" class="block text-sm font-medium text-gray-700 mb-1">Cholesterol (mg)</label>
                <input id="cholesterol" type="number" class="swal2-input w-full px-4 py-2 rounded-md border focus:ring-2 focus:ring-blue-500 focus:outline-none placeholder-gray-500" placeholder="Cholesterol" value="${ingredientData.cholesterol}" />
              </div>
            </div>
          </div>
        `,
      showCancelButton: true,
      confirmButtonColor: "#1D4ED8",
      cancelButtonColor: "#d33",
      confirmButtonText: "Save",
      cancelButtonText: "Cancel",
      customClass: {
        popup: "p-8 rounded-xl w-full max-w-4xl",
      },
      preConfirm: () => {
        const updatedData = {
          ...ingredientData,
          ingredient_name:
            Swal.getPopup().querySelector("#ingredient_name").value,
          image_url: Swal.getPopup().querySelector("#image_url").value,
          calories:
            parseFloat(Swal.getPopup().querySelector("#calories").value) || 0,
          quantity_per_unit:
            parseFloat(
              Swal.getPopup().querySelector("#quantity_per_unit").value
            ) || 0,
          protien:
            parseFloat(Swal.getPopup().querySelector("#protein").value) || 0,
          fat: parseFloat(Swal.getPopup().querySelector("#fat").value) || 0,
          carbohydrates:
            parseFloat(Swal.getPopup().querySelector("#carbohydrates").value) ||
            0,
          dietary_fiber:
            parseFloat(Swal.getPopup().querySelector("#dietary_fiber").value) ||
            0,
          calcium:
            parseFloat(Swal.getPopup().querySelector("#calcium").value) || 0,
          iron: parseFloat(Swal.getPopup().querySelector("#iron").value) || 0,
          vitamin_c:
            parseFloat(Swal.getPopup().querySelector("#vitamin_c").value) || 0,
          sodium:
            parseFloat(Swal.getPopup().querySelector("#sodium").value) || 0,
          sugar: parseFloat(Swal.getPopup().querySelector("#sugar").value) || 0,
          cholesterol:
            parseFloat(Swal.getPopup().querySelector("#cholesterol").value) ||
            0,
        };

        if (!updatedData.ingredient_name) {
          Swal.showValidationMessage("Please enter the ingredient name");
        }

        return updatedData;
      },
    }).then((result) => {
      if (result.isConfirmed) {
        handleEditIngredient(result.value);
      }
    });
  };

  return (
    <button
      onClick={showEditIngredientPopup}
      className="bg-yellow-400 hover:bg-yellow-500 text-white px-3 py-1 rounded-full shadow-md hover:shadow-lg transition duration-300 transform hover:scale-105"
    >
      Edit
    </button>
  );
};

export default IngredientEdit;

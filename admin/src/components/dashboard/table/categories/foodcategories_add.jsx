import React from "react";
import Swal from "sweetalert2";
import axios from "axios";

const FoodCategoriesAdd = ({ onAdd }) => {
  // Handle the form submission to add a new category
  const handleAddCategory = async (name, description) => {
    if (!name) {
      Swal.fire("Error", "Please provide a category name", "error");
      return;
    }

    try {
      // Call API to add a new category
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
        Swal.fire("Success", "Category added successfully", "success").then(
          () => {
            // Clear form fields (handled by the popup, so no state to reset)
            // Close the popup and refresh the list
            onAdd();
          }
        );
      } else {
        Swal.fire(
          "Error",
          response.data.message || "Failed to add category",
          "error"
        );
      }
    } catch (error) {
      Swal.fire(
        "Error",
        "An error occurred while adding the category",
        "error"
      );
    }
  };

  // Display the form in a popup using SweetAlert2
  const showAddCategoryPopup = () => {
    Swal.fire({
      title: "<h2 class='text-lg font-semibold'>Add New Category</h2>",
      html: `
        <div class="flex flex-col gap-4">
          <input id="category-name" class="swal2-input px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="Category Name" />
          <textarea id="category-description" class="swal2-textarea px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="Category Description"></textarea>
        </div>
      `,
      showCancelButton: true,
      confirmButtonColor: "#4CAF50",
      cancelButtonColor: "#d33",
      confirmButtonText: "Add",
      cancelButtonText: "Cancel",
      preConfirm: () => {
        const name = Swal.getPopup().querySelector("#category-name").value;
        const description = Swal.getPopup().querySelector(
          "#category-description"
        ).value;
        if (!name) {
          Swal.showValidationMessage("Please enter the category name");
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
      + Add Category
    </button>
  );
};

export default FoodCategoriesAdd;

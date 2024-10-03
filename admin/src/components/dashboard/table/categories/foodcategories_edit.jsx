import React from "react";
import Swal from "sweetalert2";
import axios from "axios";

const FoodCategoriesEdit = ({ category, onEdit }) => {
  // Handle the form submission to update the category
  const handleEditCategory = async (id, name, description) => {
    if (!name) {
      Swal.fire("Error", "Please provide a category name", "error");
      return;
    }

    try {
      // Call API to update the category
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
        Swal.fire("Success", "Category updated successfully", "success").then(
          () => {
            // Refresh the list in the parent component
            onEdit();
          }
        );
      } else {
        Swal.fire(
          "Error",
          response.data.message || "Failed to update category",
          "error"
        );
      }
    } catch (error) {
      Swal.fire(
        "Error",
        "An error occurred while updating the category",
        "error"
      );
    }
  };

  // Display the edit form in a popup using SweetAlert2
  const showEditCategoryPopup = () => {
    Swal.fire({
      title: "<h2 class='text-lg font-semibold'>Edit Category</h2>",
      html: `
        <div class="flex flex-col gap-4">
          <input id="category-name" class="swal2-input px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="Category Name" value="${category.category_name}" />
          <textarea id="category-description" class="swal2-textarea px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="Category Description">${category.description}</textarea>
        </div>
      `,
      showCancelButton: true,
      confirmButtonColor: "#4CAF50",
      cancelButtonColor: "#d33",
      confirmButtonText: "Update",
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
      Edit
    </button>
  );
};

export default FoodCategoriesEdit;

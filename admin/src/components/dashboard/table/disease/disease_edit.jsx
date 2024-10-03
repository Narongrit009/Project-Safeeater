import React from "react";
import Swal from "sweetalert2";
import axios from "axios";

const DiseaseEdit = ({ disease, onEdit }) => {
  // Handle the form submission for editing the disease
  const handleEditDisease = async (updatedDisease) => {
    if (!updatedDisease.name) {
      Swal.fire("Error", "Please provide a disease name", "error");
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
        Swal.fire("Success", "Disease updated successfully", "success").then(
          () => {
            // Refresh the list
            onEdit();
          }
        );
      } else {
        Swal.fire("Error", "Failed to update disease", "error");
      }
    } catch (error) {
      Swal.fire(
        "Error",
        "An error occurred while updating the disease",
        "error"
      );
    }
  };

  // Display the form in a popup using SweetAlert2
  const showEditDiseasePopup = () => {
    Swal.fire({
      title: "<h2 class='text-lg font-semibold'>Edit Disease</h2>",
      html: `
        <div class="flex flex-col gap-4">
          <input id="disease-name" class="swal2-input px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="Disease Name" value="${disease.condition_name}" />
          <textarea id="disease-description" class="swal2-textarea px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none" placeholder="Disease Description">${disease.condition_description}</textarea>
        </div>
      `,
      showCancelButton: true,
      confirmButtonColor: "#4CAF50",
      cancelButtonColor: "#d33",
      confirmButtonText: "Save",
      cancelButtonText: "Cancel",
      preConfirm: () => {
        const name = Swal.getPopup().querySelector("#disease-name").value;
        const description = Swal.getPopup().querySelector(
          "#disease-description"
        ).value;
        if (!name) {
          Swal.showValidationMessage("Please enter the disease name");
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
      Edit
    </button>
  );
};

export default DiseaseEdit;

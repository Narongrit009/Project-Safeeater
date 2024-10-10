import React, { useState, useEffect } from "react";
import axios from "axios";
import { useParams, useNavigate } from "react-router-dom";
import Sidebar from "../../sidebar.jsx";
import Navbar from "../../navbar.jsx";
import Swal from "sweetalert2";

const FoodMenuEdit = () => {
  const { menuId } = useParams(); // รับ menuId จาก URL
  const [menuName, setMenuName] = useState("");
  const [category, setCategory] = useState(""); // จะเก็บ category_id ที่เลือก
  const [categories, setCategories] = useState([]);
  const [categoryName, setCategoryName] = useState(""); // เก็บ category_name ที่ดึงมาจาก API
  const [imageUrl, setImageUrl] = useState("");
  const [healthCondition, setHealthCondition] = useState(""); // จะเก็บ health_condition_id ที่เลือก
  const [healthConditionName, setHealthConditionName] = useState(""); // เก็บ condition_name ที่ดึงมาจาก API
  const [healthConditions, setHealthConditions] = useState([]);
  const [relatedConditions, setRelatedConditions] = useState([]); // เก็บ related_conditions ที่ดึงมาจาก API
  const [selectedRelatedConditions, setSelectedRelatedConditions] = useState(
    []
  ); // เก็บ condition_id ของโรคที่เลือก
  const [ingredients, setIngredients] = useState([]);
  const [selectedIngredients, setSelectedIngredients] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const navigate = useNavigate();

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen);
  };

  useEffect(() => {
    // ดึงข้อมูลเมนูที่ต้องการแก้ไข
    const fetchMenuData = async () => {
      setLoading(true);
      try {
        const response = await axios.get(
          `${
            import.meta.env.VITE_API_URL_GET_FOOD_MENU_DETAIL
          }?menu_id=${menuId}`
        );
        const menuData = response.data.data;

        setMenuName(menuData.menu_name);
        setImageUrl(menuData.image_url);
        setCategory(menuData.category_id || ""); // ดึงค่า category_id มาใช้
        setCategoryName(menuData.category_name || ""); // ดึง category_name มาใช้
        setHealthCondition(menuData.health_condition || ""); // ดึงค่า health_condition มาใช้
        setHealthConditionName(menuData.condition_name || ""); // ดึง condition_name มาใช้
        setSelectedIngredients(
          menuData.ingredients_id ? menuData.ingredients_id.split(", ") : []
        ); // ตรวจสอบค่า null ก่อนใช้ split()
        setSelectedRelatedConditions(
          menuData.related_conditions_id
            ? menuData.related_conditions_id.split(", ")
            : []
        ); // ใช้ related_conditions_id แทน
        setLoading(false);
      } catch (err) {
        console.error("Error fetching menu data:", err);
        setError(err);
        setLoading(false);
      }
    };

    // ดึงประเภทอาหาร
    const fetchCategories = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_FOOD_CATEGORIES}`
        );
        setCategories(response.data);
      } catch (err) {
        console.error("Error fetching categories:", err);
      }
    };

    // ดึงวัตถุดิบทั้งหมด
    const fetchIngredients = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_INGREDIENTS}`
        );
        setIngredients(response.data);
      } catch (err) {
        console.error("Error fetching ingredients:", err);
      }
    };

    // ดึงโรคที่เกี่ยวข้อง
    const fetchRelatedConditions = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_DISEASES}`
        );
        setRelatedConditions(response.data);
      } catch (err) {
        console.error("Error fetching related conditions:", err);
      }
    };

    const fetchHealthConditions = async () => {
      try {
        const response = await axios.get(
          `${import.meta.env.VITE_API_URL_GET_DISEASES}`
        );
        console.log("Health conditions data:", response.data); // ตรวจสอบข้อมูลที่ได้รับ
        setHealthConditions(Array.isArray(response.data) ? response.data : []); // ตรวจสอบว่าข้อมูลเป็น array
      } catch (err) {
        console.error("Error fetching health conditions:", err);
        setHealthConditions([]); // กรณีเกิดข้อผิดพลาด ให้ตั้งเป็น array ว่าง
      }
    };

    fetchMenuData();
    fetchCategories();
    fetchIngredients();
    fetchRelatedConditions();
    fetchHealthConditions();
  }, [menuId]);

  const handleIngredientChange = (ingredientId) => {
    setSelectedIngredients((prevSelected) => {
      if (prevSelected.includes(ingredientId)) {
        return prevSelected.filter((id) => id !== ingredientId);
      } else {
        return [...prevSelected, ingredientId];
      }
    });
  };

  const handleRemoveIngredient = (ingredientId) => {
    setSelectedIngredients((prevSelected) =>
      prevSelected.filter((id) => id !== ingredientId)
    );
  };

  // ฟังก์ชันจัดการการเลือกโรคที่เหมาะสม
  const handleHealthConditionChange = (e) => {
    const conditionId = e.target.value;
    const selectedCondition = healthConditions.find(
      (c) => c.condition_id === parseInt(conditionId)
    );

    // ตรวจสอบว่า "ไม่มี" สามารถเลือกซ้ำได้
    if (selectedCondition.condition_name === "ไม่มี") {
      setHealthCondition(conditionId);
      return;
    }

    // ไม่ให้เลือกซ้ำกับ "เลือกโรคที่เกี่ยวข้อง"
    if (selectedRelatedConditions.includes(parseInt(conditionId))) {
      Swal.fire({
        icon: "warning",
        title: "เลือกโรคซ้ำกัน",
        text: "คุณไม่สามารถเลือกโรคนี้ได้ในทั้งสองตำแหน่ง",
      });
      return;
    }

    setHealthCondition(conditionId);
  };

  // ฟังก์ชันจัดการการเลือกโรคที่เกี่ยวข้อง
  const handleRelatedConditionChange = (conditionId) => {
    const selectedCondition = relatedConditions.find(
      (c) => c.condition_id === conditionId
    );

    // ตรวจสอบว่า "ไม่มี" สามารถเลือกซ้ำได้
    if (selectedCondition.condition_name === "ไม่มี") {
      setSelectedRelatedConditions((prevSelected) => {
        if (prevSelected.includes(conditionId)) {
          return prevSelected.filter((item) => item !== conditionId);
        } else {
          return [...prevSelected, conditionId];
        }
      });
      return;
    }

    // ไม่ให้เลือกซ้ำกับ "เหมาะสมกับโรค"
    if (healthCondition === conditionId) {
      Swal.fire({
        icon: "warning",
        title: "เลือกโรคซ้ำกัน",
        text: "คุณไม่สามารถเลือกโรคนี้ได้ในทั้งสองตำแหน่ง",
      });
      return;
    }

    setSelectedRelatedConditions((prevSelected) => {
      if (prevSelected.includes(conditionId)) {
        return prevSelected.filter((item) => item !== conditionId);
      } else {
        return [...prevSelected, conditionId];
      }
    });
  };

  const handleRemoveRelatedCondition = (conditionId) => {
    setSelectedRelatedConditions((prevSelected) =>
      prevSelected.filter((item) => item !== conditionId)
    );
  };

  const handleSave = async (e) => {
    e.preventDefault();
    setError(null);
    setSuccess(null);

    // ตรวจสอบความถูกต้องของข้อมูล
    if (
      !menuName ||
      !imageUrl ||
      !category ||
      !healthCondition ||
      selectedIngredients.length === 0 ||
      selectedRelatedConditions.length === 0
    ) {
      setError({
        message:
          "กรุณากรอกข้อมูลในทุกฟิลด์และเลือกวัตถุดิบและโรคที่เกี่ยวข้องอย่างน้อยหนึ่งรายการ",
      });
      return;
    }

    setLoading(true);

    const formData = {
      menu_id: menuId, // ส่ง menu_id ไปด้วย
      menu_name: menuName,
      category: category,
      image_url: imageUrl,
      health_condition: healthCondition,
      ingredients: selectedIngredients,
      related_conditions: selectedRelatedConditions, // ส่งข้อมูล id ของโรคที่เกี่ยวข้อง
    };

    // console.log("Data to be sent:", formData);

    try {
      await axios.put(
        `${import.meta.env.VITE_API_URL_UPDATE_FOOD_MENU}/${menuId}`, // ส่ง menuId ใน URL
        formData
      );
      Swal.fire({
        icon: "success",
        title: "แก้ไขเมนูอาหารสำเร็จ!",
        text: "ข้อมูลได้ถูกแก้ไขแล้ว",
      }).then(() => {
        // หลังจากการแสดงผลเสร็จสิ้นให้ไปยัง /foodmenu
        navigate("/foodmenu");
      });
    } catch (err) {
      setError(err);
    } finally {
      setLoading(false);
    }
  };

  const filteredIngredients = ingredients.filter((ingredient) =>
    ingredient.ingredient_name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="min-h-screen flex bg-gradient-to-br from-gray-100 to-gray-300">
      <Sidebar isSidebarOpen={isSidebarOpen} />
      <div className="flex-1 p-10">
        <Navbar toggleSidebar={toggleSidebar} />
        <h1 className="text-4xl font-bold text-center mb-12 text-gray-900">
          แก้ไขเมนูอาหาร
        </h1>

        <form
          onSubmit={handleSave}
          className="max-w-6xl mx-auto bg-white p-10 rounded-xl shadow-2xl"
        >
          <div className="grid grid-cols-1 md:grid-cols-2 gap-10 mb-10">
            {/* ฟิลด์ข้อมูลต่าง ๆ ของเมนู */}
            <div>
              <label className="block text-xl text-gray-700 mb-3">
                ชื่อเมนูอาหาร:
              </label>
              <input
                type="text"
                value={menuName}
                onChange={(e) => setMenuName(e.target.value)}
                className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
                required
              />
            </div>

            <div>
              <label className="block text-xl text-gray-700 mb-3">
                ลิงก์รูปภาพเมนู:
              </label>
              <input
                type="text"
                value={imageUrl}
                onChange={(e) => setImageUrl(e.target.value)}
                className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
                required
              />
            </div>

            <div>
              <label className="block text-xl text-gray-700 mb-3">
                ประเภทอาหาร:
              </label>
              <select
                value={category}
                onChange={(e) => setCategory(e.target.value)}
                className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
                required
              >
                <option value="">
                  {categoryName || "-- เลือกประเภทอาหาร --"}
                </option>
                {categories.map((cat) => (
                  <option key={cat.id} value={cat.id}>
                    {cat.category_name}
                  </option>
                ))}
              </select>
            </div>

            <div>
              <label className="block text-xl text-gray-700 mb-3">
                เหมาะสมกับโรค:
              </label>
              <select
                value={healthCondition}
                onChange={(e) => setHealthCondition(e.target.value)}
                className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
                required
              >
                <option value="">
                  {healthConditionName || "-- เลือกโรคที่เหมาะสม --"}
                </option>
                {healthConditions.map((condition) => (
                  <option
                    key={condition.condition_id}
                    value={condition.condition_id}
                  >
                    {condition.condition_name}
                  </option>
                ))}
              </select>
            </div>
          </div>

          {/* ส่วนเลือกวัตถุดิบ */}
          <div className="mb-8">
            <label className="block text-xl text-gray-700 mb-3">
              ค้นหาวัตถุดิบ:
            </label>
            <input
              type="text"
              placeholder="ค้นหาวัตถุดิบ..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full px-4 py-3 border rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 text-lg"
            />
          </div>

          <div className="mb-10">
            <label className="block text-xl text-gray-700 mb-3">
              วัตถุดิบของเมนู:
            </label>
            <div className="p-4 border rounded-lg bg-gray-100 flex flex-wrap gap-3">
              {selectedIngredients.length > 0 ? (
                selectedIngredients.map((ingredientId) => {
                  const ingredient = ingredients.find(
                    (ing) => ing.ingredient_id === ingredientId
                  );
                  return (
                    <div
                      key={ingredientId}
                      className="flex items-center bg-blue-200 text-blue-800 px-3 py-1 rounded-full text-sm font-semibold mr-2 mb-2"
                    >
                      {ingredient?.ingredient_name || "ไม่ทราบชื่อ"}
                      <button
                        className="ml-2 text-red-500 hover:text-red-700"
                        onClick={() => handleRemoveIngredient(ingredientId)}
                      >
                        &times;
                      </button>
                    </div>
                  );
                })
              ) : (
                <p className="text-gray-500">ยังไม่มีวัตถุดิบที่ถูกเลือก</p>
              )}
            </div>
          </div>

          <div className="mb-10">
            <label className="block text-xl text-gray-700 mb-5">
              วัตถุดิบ:
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 max-h-96 overflow-y-auto">
              {filteredIngredients.map((ingredient) => (
                <div
                  key={ingredient.ingredient_id}
                  className={`flex flex-col items-center p-4 border rounded-lg shadow-sm transition duration-300 cursor-pointer ${
                    selectedIngredients.includes(ingredient.ingredient_id)
                      ? "bg-blue-100 border-blue-500"
                      : "bg-white hover:shadow-lg"
                  }`}
                  onClick={() =>
                    handleIngredientChange(ingredient.ingredient_id)
                  }
                >
                  <img
                    src={ingredient.image_url}
                    alt={ingredient.ingredient_name}
                    className="w-24 h-24 object-cover mb-3 rounded-lg"
                  />
                  <span className="text-center text-sm font-semibold mb-2">
                    {ingredient.ingredient_name}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {/* ส่วนเลือกโรคที่เกี่ยวข้อง */}
          <div className="mb-10">
            <label className="block text-xl text-gray-700 mb-3">
              โรคที่เกี่ยวข้อง:
            </label>
            <div className="p-4 border rounded-lg bg-gray-100 flex flex-wrap gap-3">
              {selectedRelatedConditions.length > 0 ? (
                selectedRelatedConditions.map((conditionId, index) => {
                  const condition = relatedConditions.find(
                    (cond) => cond.condition_id === conditionId
                  );
                  return (
                    <div
                      key={index}
                      className="flex items-center bg-green-200 text-green-800 px-3 py-1 rounded-full text-sm font-semibold mr-2 mb-2"
                    >
                      {condition?.condition_name || "ไม่ทราบชื่อ"}
                      <button
                        className="ml-2 text-red-500 hover:text-red-700"
                        onClick={() =>
                          handleRemoveRelatedCondition(conditionId)
                        }
                      >
                        &times;
                      </button>
                    </div>
                  );
                })
              ) : (
                <p className="text-gray-500">ยังไม่มีโรคที่ถูกเลือก</p>
              )}
            </div>
          </div>

          <div className="mb-10">
            <label className="block text-xl text-gray-700 mb-5">
              เลือกโรคที่เกี่ยวข้อง:
            </label>
            <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-6 max-h-96 overflow-y-auto">
              {relatedConditions.map((condition) => (
                <div
                  key={condition.condition_id}
                  className={`flex flex-col items-center p-4 border rounded-lg shadow-sm transition duration-300 cursor-pointer ${
                    selectedRelatedConditions.includes(condition.condition_id)
                      ? "bg-green-100 border-green-500"
                      : "bg-white hover:shadow-lg"
                  }`}
                  onClick={() =>
                    handleRelatedConditionChange(condition.condition_id)
                  }
                >
                  <span className="text-center text-sm font-semibold mb-2">
                    {condition.condition_name}
                  </span>
                </div>
              ))}
            </div>
          </div>

          {error && (
            <div className="text-red-600 mb-4 text-center">{error.message}</div>
          )}
          {success && (
            <div className="text-green-600 mb-4 text-center">{success}</div>
          )}

          <button
            type="submit"
            className="w-full py-4 bg-gradient-to-r from-blue-500 to-purple-500 text-white rounded-lg text-xl font-bold hover:from-blue-600 hover:to-purple-600 transition duration-300 shadow-lg hover:shadow-2xl"
            disabled={loading}
          >
            {loading ? "กำลังบันทึก..." : "บันทึกการเปลี่ยนแปลง"}
          </button>
        </form>
      </div>
    </div>
  );
};

export default FoodMenuEdit;

require('init')

data:extend(
    {
        {
            type = "custom-input",
            name = RecipeLogisticRequest.hotkey_names.request_increase_1_result,
            order = RecipeLogisticRequest.prefix_with_mod_name('01'),
            key_sequence = "ALT + mouse-button-1",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = RecipeLogisticRequest.hotkey_names.request_increase_5_result,
            order = RecipeLogisticRequest.prefix_with_mod_name('02'),
            key_sequence = "ALT + mouse-button-2",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = RecipeLogisticRequest.hotkey_names.request_decrease_1_result,
            order = RecipeLogisticRequest.prefix_with_mod_name('03'),
            key_sequence = "",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = RecipeLogisticRequest.hotkey_names.request_decrease_5_result,
            order = RecipeLogisticRequest.prefix_with_mod_name('04'),
            key_sequence = "",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = RecipeLogisticRequest.hotkey_names.request_increase_1_ingredients,
            order = RecipeLogisticRequest.prefix_with_mod_name('05'),
            key_sequence = "CONTROL + ALT + mouse-button-1",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = RecipeLogisticRequest.hotkey_names.request_increase_5_ingredients,
            order = RecipeLogisticRequest.prefix_with_mod_name('06'),
            key_sequence = "CONTROL + ALT + mouse-button-2",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = RecipeLogisticRequest.hotkey_names.request_decrease_1_ingredients,
            order = RecipeLogisticRequest.prefix_with_mod_name('07'),
            key_sequence = "",
            consuming = "game-only",
            include_selected_prototype = true
        },
        {
            type = "custom-input",
            name = RecipeLogisticRequest.hotkey_names.request_decrease_5_ingredients,
            order = RecipeLogisticRequest.prefix_with_mod_name('08'),
            key_sequence = "",
            consuming = "game-only",
            include_selected_prototype = true
        },
    }
)
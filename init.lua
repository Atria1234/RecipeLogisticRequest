RecipeLogisticRequest = { }

RecipeLogisticRequest.mod_name = 'RecipeLogisticRequest'

function RecipeLogisticRequest.prefix_with_mod_name(value)
    return RecipeLogisticRequest.mod_name..'__'..value
end

RecipeLogisticRequest.hotkey_names = {
    request_increase_1_result = RecipeLogisticRequest.prefix_with_mod_name('increase-request-result'),
    request_increase_5_result = RecipeLogisticRequest.prefix_with_mod_name('increase-request-result-5'),
    request_decrease_1_result = RecipeLogisticRequest.prefix_with_mod_name('decrease-request-result'),
    request_decrease_5_result = RecipeLogisticRequest.prefix_with_mod_name('decrease-request-result-5'),

    request_increase_1_ingredients = RecipeLogisticRequest.prefix_with_mod_name('increase-request-ingredients'),
    request_increase_5_ingredients = RecipeLogisticRequest.prefix_with_mod_name('increase-request-ingredients-5'),
    request_decrease_1_ingredients = RecipeLogisticRequest.prefix_with_mod_name('decrease-request-ingredients'),
    request_decrease_5_ingredients = RecipeLogisticRequest.prefix_with_mod_name('decrease-request-ingredients-5'),
}

function RecipeLogisticRequest.get_logistic_section_name(player)
    return player.name..'\'s requests'
end

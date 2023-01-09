function modify_requests(character, items)
    -- modify already existing requests
    for slot = 1, character.request_slot_count do
        local request = character.get_personal_logistic_slot(slot)
        local requested_item = request.name
        local requested_count = items[requested_item]
        if requested_item and requested_count then
            if requested_count > 0 then
                request.min = request.min + requested_count
                if request.max < 4294967295 then
                    request.max = request.max + requested_count
                end

                character.set_personal_logistic_slot(slot, request)
            else
                if request.min + requested_count <= 0 and (request.max + requested_count <= 0 or request.max == 4294967295) then
                    character.clear_personal_logistic_slot(slot)
                else
                    request.min = math.max(request.min + requested_count, 0)
                    if request.max < 4294967295 then
                        request.max = request.max + requested_count
                    end

                    character.set_personal_logistic_slot(slot, request)
                end
            end
            items[requested_item] = nil
        end
    end

    -- create new requests
    local next = next
    for slot = 1, 65536 do
        if next(items) == nil then
            break
        end

        local request = character.get_personal_logistic_slot(slot)
        if request.name == nil then
            local name, count = next(items)
            if count > 0 then
                character.set_personal_logistic_slot(slot, {
                    name = name,
                    min = count,
                    max = nil
                })
            end
            items[name] = nil
        end
    end
end

function get_recipe_requests(ingredients_or_products, multiplier)
    local items = {}
    for _, item in ipairs(ingredients_or_products) do
        if item.type == "item" then
            items[item.name] = multiplier * (item.amount or 1)
        end
    end
    return items
end

function create_event_handler(use_result, multiplier)
    function handler(event)
        local player = game.players[event.player_index]
        if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
            if player ~= nil and player.valid and player.character ~= nil and player.character.valid then
                local recipe = player.character.force.recipes[event.selected_prototype.name]
                if use_result then
                    modify_requests(player.character, get_recipe_requests(recipe.products, multiplier))
                else
                    modify_requests(player.character, get_recipe_requests(recipe.ingredients, multiplier))
                end
            end
        end
    end

    return handler
end

script.on_event("RecipeLogisticRequest__increase-request-result", create_event_handler(true, 1))
script.on_event("RecipeLogisticRequest__increase-request-result-5", create_event_handler(true, 5))

script.on_event("RecipeLogisticRequest__decrease-request-result", create_event_handler(true, -1))
script.on_event("RecipeLogisticRequest__decrease-request-result-5", create_event_handler(true, -5))

script.on_event("RecipeLogisticRequest__increase-request-ingredients", create_event_handler(false, 1))
script.on_event("RecipeLogisticRequest__increase-request-ingredients-5", create_event_handler(false, 5))

script.on_event("RecipeLogisticRequest__decrease-request-ingredients", create_event_handler(false, -1))
script.on_event("RecipeLogisticRequest__decrease-request-ingredients-5", create_event_handler(false, -5))

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

        if next(items) == nil then
            break
        end
    end
end

function get_valid_event_character(event)
    local player = game.players[event.player_index]
    if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
        if player ~= nil and player.valid and player.character ~= nil and player.character.valid then
            return player.character
        end
    end
    return nil
end

function get_recipe_ingredients(recipe, multiplier)
    local items = {}
    for _, ingredients in ipairs(recipe.ingredients) do
        if ingredients.type == "item" then
            items[ingredients.name] = multiplier * ingredients.amount
        end
    end
    return items
end

script.on_event("RecipeLogisticRequest__increase-request-result", function(event)
    local character = get_valid_event_character(event)
    if character ~= nil then
        modify_requests(character, {[event.selected_prototype.name] = 1})
    end
end)

script.on_event("RecipeLogisticRequest__decrease-request-result", function(event)
    local character = get_valid_event_character(event)
    if character ~= nil then
        modify_requests(character, {[event.selected_prototype.name] = -1})
    end
end)

script.on_event("RecipeLogisticRequest__increase-request-ingredients", function(event)
    local character = get_valid_event_character(event)
    if character ~= nil then
        local recipe = character.force.recipes[event.selected_prototype.name]
        modify_requests(character, get_recipe_ingredients(recipe, 1))
    end
end)

script.on_event("RecipeLogisticRequest__decrease-request-ingredients", function(event)
    local character = get_valid_event_character(event)
    if character ~= nil then
        local recipe = character.force.recipes[event.selected_prototype.name]
        modify_requests(character, get_recipe_ingredients(recipe, -1))
    end
end)

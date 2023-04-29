local infinity = 4294967295
local max_request_slot = 65536

local function modify_requests(character, requested_items)
    -- modify already existing requests
    for slot = 1, character.request_slot_count do
        local request = character.get_personal_logistic_slot(slot)
        local requested_count = requested_items[request.name]
        if request.name ~= nil and requested_count ~= nil then
            if requested_count > 0 then
                request.min = request.min + requested_count
                request.max = math.min(request.max + requested_count, infinity)

                character.set_personal_logistic_slot(slot, request)
            else
                if request.min + requested_count <= 0 and (request.max + requested_count <= 0 or request.max == infinity) then
                    character.clear_personal_logistic_slot(slot)
                else
                    request.min = math.max(request.min + requested_count, 0)
                    request.max = request.max < infinity and math.min(request.max + requested_count, infinity) or infinity

                    character.set_personal_logistic_slot(slot, request)
                end
            end

            requested_items[request.name] = nil
        end
    end

    -- create new requests
    for slot = 1, max_request_slot do
        if next(requested_items) == nil then
            break
        end

        local request = character.get_personal_logistic_slot(slot)
        if request.name == nil then
            local requested_name, requested_count = next(requested_items)
            if requested_count > 0 then
                character.set_personal_logistic_slot(slot, {
                    name = requested_name,
                    min = requested_count,
                    max = nil
                })
            end

            requested_items[requested_name] = nil
        end
    end
end

local function get_recipe_requests(ingredients_or_products, multiplier)
    local items = {}
    for _, item in ipairs(ingredients_or_products) do
        if item.type == "item" then
            items[item.name] = multiplier * (item.amount or 1)
        end
    end

    return items
end

local function create_event_handler(use_result, multiplier)
    local function handler(event)
        local player = game.players[event.player_index]
        if player ~= nil and player.valid and player.character ~= nil and player.character.valid then
            if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
                local recipe = player.character.force.recipes[event.selected_prototype.name]
                modify_requests(player.character, get_recipe_requests(use_result and recipe.products or recipe.ingredients, multiplier))
            elseif event.selected_prototype and event.selected_prototype.base_type == "item" then
                if use_result then
                    modify_requests(player.character, {
                        [event.selected_prototype.name] = multiplier
                    })
                end
            elseif event.selected_prototype and event.selected_prototype.base_type == "entity" then
                local entity_name = event.selected_prototype.name
                if event.selected_prototype.name == 'entity-ghost' then
                    local ghost_entity = player.surface.find_entity(event.selected_prototype.name, event.cursor_position)
                    if ghost_entity then
                        entity_name = ghost_entity.ghost_name
                    end
                end

                if use_result then
                    local items_to_place_this = game.entity_prototypes[entity_name].items_to_place_this
                    if items_to_place_this and table_size(items_to_place_this) == 1 then
                        modify_requests(player.character, {
                            [items_to_place_this[1].name] = multiplier
                        })
                    end
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

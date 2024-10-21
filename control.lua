local infinity = 4294967295
local max_request_slot = 65536

local function modify_requests(character, requested_items)      
    local requester_point = character.get_requester_point()
    -- If logistics hasn't been researched then this will return nil and we can't do anything
    if requester_point == nil then
        return
    end
    local section_name = "automatic-recipe-requests"
    local chosen_section = nil

    for i = 1, requester_point.sections_count do
        local section = requester_point.get_section(i)
        if section.group == section_name then
            chosen_section = section
            break
        end        
    end

    if chosen_section == nil then
        chosen_section = requester_point.add_section(section_name)
        for i = 1, chosen_section.filters_count do
            chosen_section.clear_slot(i)
        end
    end

    local unused_slots = {}

    for i = 1, chosen_section.filters_count do
        local filter = chosen_section.filters[i]
        if filter and filter.value and requested_items[filter.value.name] then
            local item = filter.value.name            
            local updated_filter = {
                value = item,
                min = filter.min + requested_items[item],
            }
            if filter.max then
                updated_filter.max = math.min(filter.max + requested_items[item], infinity)
            end
            chosen_section.set_slot(i, updated_filter)
            requested_items[filter.value.name] = nil
        elseif filter == nil or filter.value == nil then
            table.insert(unused_slots, i)
        end
    end

    for item, count in pairs(requested_items) do
        local slot_index = table.remove(unused_slots, 1)
        local filter = {
            value = item,
            min = count,
            max = nil
        }        
        if slot_index then
            chosen_section.set_slot(slot_index, filter)
        else
            chosen_section.set_slot(chosen_section.filters_count + 1, filter)
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

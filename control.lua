require('init')

local function get_request_logistic_section(player, logistic_point, or_create)
    local section_name = RecipeLogisticRequest.get_logistic_section_name(player)
    for _, section in ipairs(logistic_point.sections) do
        if section.group == section_name then
            return section
        end
    end

    if or_create then
        local section = logistic_point.add_section(section_name)
        for i = 1, section.filters_count do
            section.clear_slot(i)
        end
        return section
    end

    return nil
end

local function modify_requests(player, requested_items)
    player.play_sound({path='utility/inventory_click'})

    local character = player.character

    local logistic_point = character.get_logistic_point(defines.logistic_member_index.character_requester)
    if logistic_point then
        local section = get_request_logistic_section(player, logistic_point, true)

        for i, request in ipairs(section.filters) do
            if request.value then
                local requested_name = request.value.name
                local requested_count = requested_items[requested_name]
                if requested_count then
                    request.min = request.min + requested_count

                    if request.min > 0 then
                        section.set_slot(i, request)
                    else
                        section.clear_slot(i)
                    end

                    requested_items[requested_name] = nil
                end
            end
        end

        -- create new requests
        local i = 1
        for requested_name, requested_count in pairs(requested_items) do
            if requested_count > 0 then
                while section.get_slot(i).value do
                    i = i + 1
                end
                section.set_slot(i, {
                    value = requested_name,
                    min = requested_count
                })
            end
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

local function create_recipe_flying_text(player, use_result, count)
    player.create_local_flying_text({
        text = {
            'flying-text.RecipeLogisticRequest__request-'..(count > 0 and 'increased' or 'decreased'),
            {
                use_result and 'flying-text.RecipeLogisticRequest__recipe-products' or 'flying-text.RecipeLogisticRequest__recipe-ingredients'
            },
            math.abs(count)
        },
        create_at_cursor = true
    })
end

local function create_item_flying_text(player, item_name, count)
    player.create_local_flying_text({
        text = {
            'flying-text.RecipeLogisticRequest__request-'..(count > 0 and 'increased' or 'decreased'),
            {
                '?',
                {'item-name.'..item_name},
                {'entity-name.'..item_name},
                item_name
            },
            math.abs(count)
        },
        create_at_cursor = true
    })
end

local function create_event_handler(use_result, multiplier)
    local function handler(event)
        local player = game.players[event.player_index]
        if player ~= nil and player.valid and player.character ~= nil and player.character.valid then
            if event.selected_prototype and event.selected_prototype.base_type == "recipe" then
                local recipe = player.character.force.recipes[event.selected_prototype.name]
                local requests = get_recipe_requests(use_result and recipe.products or recipe.ingredients, multiplier)
                if table_size(requests) == 1 then
                    create_item_flying_text(player, next(requests))
                else
                    create_recipe_flying_text(player, use_result, multiplier)
                end

                modify_requests(player, requests)
            elseif event.selected_prototype and event.selected_prototype.base_type == "item" then
                if use_result then
                    create_item_flying_text(player, event.selected_prototype.name, multiplier)

                    modify_requests(player, {
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
                    local items_to_place_this = prototypes.entity[entity_name].items_to_place_this
                    if items_to_place_this and table_size(items_to_place_this) == 1 then
                        create_item_flying_text(player, items_to_place_this[1].name, multiplier)

                        modify_requests(player, {
                            [items_to_place_this[1].name] = multiplier
                        })
                    end
                end
            end
        end
    end

    return handler
end

script.on_event(RecipeLogisticRequest.hotkey_names.request_increase_1_result, create_event_handler(true, 1))
script.on_event(RecipeLogisticRequest.hotkey_names.request_increase_5_result, create_event_handler(true, 5))
script.on_event(RecipeLogisticRequest.hotkey_names.request_decrease_1_result, create_event_handler(true, -1))
script.on_event(RecipeLogisticRequest.hotkey_names.request_decrease_5_result, create_event_handler(true, -5))

script.on_event(RecipeLogisticRequest.hotkey_names.request_increase_1_ingredients, create_event_handler(false, 1))
script.on_event(RecipeLogisticRequest.hotkey_names.request_increase_5_ingredients, create_event_handler(false, 5))
script.on_event(RecipeLogisticRequest.hotkey_names.request_decrease_1_ingredients, create_event_handler(false, -1))
script.on_event(RecipeLogisticRequest.hotkey_names.request_decrease_5_ingredients, create_event_handler(false, -5))

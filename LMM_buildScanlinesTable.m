function tableOut = LMM_buildScanlinesTable(bestScanlines)
    inType = whos('bestScanlines');
    if inType.class == "table"
        HeadersA = {'Group'};
        G = strings(height(bestScanlines), 1);
        G(:) = "None";
        G = array2table(G);
        G.Properties.VariableNames = HeadersA;
        
        Headers1 = {'ConversionMessage'};
        CM = strings(height(bestScanlines), 1);
        CM(:) = "No_scanlines_identified";
        CM = array2table(CM);
        CM.Properties.VariableNames = Headers1;

        Headers2 = {'Selected'};
        Selected = strings(height(bestScanlines), 1);
        Selected(:) = "Not_Used";
        Selected = array2table(Selected);
        Selected.Properties.VariableNames = Headers2;

        tableOut = [Selected, CM, G, bestScanlines];
        
    else
        primaryRow = bestScanlines.PRIMARY;
        primaryGroup = bestScanlines.PRIMARY_GROUP;

        secondaryRow = bestScanlines.SECONDARY;
        secondaryGroup = bestScanlines.SECONDARY_GROUP;

        tertiaryRow = bestScanlines.TERTIARY;
        tertiaryGroup = bestScanlines.TERTIARY_GROUP;


        % Primary
        HeadersA = {'Group'};
        G = strings(height(primaryRow), 1);
        G(:) = {"Primary"};
        G = array2table(G);
        G.Properties.VariableNames = HeadersA;

        primaryRow = [G,primaryRow];

        G = strings(height(primaryGroup), 1);
        G(:) = {"Primary"};
        G = array2table(G);
        G.Properties.VariableNames = HeadersA;

        primaryGroup = [G,primaryGroup];

        try
        % Secondary
        G = strings(height(secondaryRow), 1);
        G(:) = {"Secondary"};
        G = array2table(G);
        G.Properties.VariableNames = HeadersA;

        secondaryRow = [G,secondaryRow];

        G = strings(height(secondaryGroup), 1);
        G(:) = {"Secondary"};
        G = array2table(G);
        G.Properties.VariableNames = HeadersA;

        secondaryGroup = [G,secondaryGroup];
        catch
        end

        try
        % Tertiary
        G = strings(height(tertiaryRow), 1);
        G(:) = {"Tertiary"};
        G = array2table(G);
        G.Properties.VariableNames = HeadersA;

        tertiaryRow = [G,tertiaryRow];

        G = strings(height(tertiaryGroup), 1);
        G(:) = {"Tertiary"};
        G = array2table(G);
        G.Properties.VariableNames = HeadersA;

        tertiaryGroup = [G,tertiaryGroup];

        catch
        end



        tableOutA = [primaryRow; secondaryRow; tertiaryRow];
        tableOutB = [primaryGroup; secondaryGroup; tertiaryGroup];


        Headers1 = {'ConversionMessage'};
        CM = strings(height(tableOutA), 1);
        CM(:) = {bestScanlines.MESSAGES};
        CM = array2table(CM);
        CM.Properties.VariableNames = Headers1;

        Headers2 = {'Selected'};
        Selected = strings(height(tableOutA), 1);
        Selected(:) = "Used";
        Selected = array2table(Selected);
        Selected.Properties.VariableNames = Headers2;

        Headers1 = {'ConversionMessage'};
        CM2 = strings(height(tableOutB), 1);
        CM2(:) = {"Intermediate_Data"};
        CM2 = array2table(CM2);
        CM2.Properties.VariableNames = Headers1;

        Headers2 = {'Selected'};
        Selected2 = strings(height(tableOutB), 1);
        Selected2(:) = "Not_Used";
        Selected2 = array2table(Selected2);
        Selected2.Properties.VariableNames = Headers2;

        tableOutA = [Selected, CM, tableOutA];
        tableOutB = [Selected2, CM2, tableOutB];

        tableOut = [tableOutA;tableOutB];
    end

end
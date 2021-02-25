function imgPrint = LMM_overlay1cmLinePts(CONVERSION_METHOD,VAL,imgPrint,SCx,SCy,linePtsX,linePtsY)

    if CONVERSION_METHOD == "Harris"
        imgPrint(SCy,SCx,1) = 0; %blue
        imgPrint(SCy,SCx,2) = 255; %blue
        imgPrint(SCy,SCx,3) = 255; %blue
        
        if (VAL == "Gray_SingleValidation") || (VAL == "Gray_SingleValidation_MinWVar")% if single val, line is red
            imgPrint(linePtsY,linePtsX,1) = 255; %red
            imgPrint(linePtsY,linePtsX,2) = 0; %red
            imgPrint(linePtsY,linePtsX,3) = 0; %red

            imgPrint(linePtsY+1,linePtsX,1) = 255; %red
            imgPrint(linePtsY+1,linePtsX,2) = 0; %red
            imgPrint(linePtsY+1,linePtsX,3) = 0; %red

            imgPrint(linePtsY-1,linePtsX,1) = 255; %red
            imgPrint(linePtsY-1,linePtsX,2) = 0; %red
            imgPrint(linePtsY-1,linePtsX,3) = 0; %red
        else
            imgPrint(linePtsY,linePtsX,1) = 0; %blue
            imgPrint(linePtsY,linePtsX,2) = 255; %blue
            imgPrint(linePtsY,linePtsX,3) = 255; %blue

            imgPrint(linePtsY+1,linePtsX,1) = 0; %blue
            imgPrint(linePtsY+1,linePtsX,2) = 255; %blue
            imgPrint(linePtsY+1,linePtsX,3) = 255; %blue

            imgPrint(linePtsY-1,linePtsX,1) = 0; %blue
            imgPrint(linePtsY-1,linePtsX,2) = 255; %blue
            imgPrint(linePtsY-1,linePtsX,3) = 255; %blue
        end

    elseif CONVERSION_METHOD == "Peaks"
        imgPrint(SCy,SCx,1) = 0; %green
        imgPrint(SCy,SCx,2) = 255; %green
        imgPrint(SCy,SCx,3) = 0; %green

        if (VAL == "Gray_SingleValidation") || (VAL == "Gray_SingleValidation_MinWVar") % if single val, line is red
            imgPrint(linePtsY,linePtsX,1) = 255; %red
            imgPrint(linePtsY,linePtsX,2) = 0; %red
            imgPrint(linePtsY,linePtsX,3) = 0; %red

            imgPrint(linePtsY+1,linePtsX,1) = 255; %red
            imgPrint(linePtsY+1,linePtsX,2) = 0; %red
            imgPrint(linePtsY+1,linePtsX,3) = 0; %red

            imgPrint(linePtsY-1,linePtsX,1) = 255; %red
            imgPrint(linePtsY-1,linePtsX,2) = 0; %red
            imgPrint(linePtsY-1,linePtsX,3) = 0; %red
        else
            imgPrint(linePtsY,linePtsX,1) = 0; %green
            imgPrint(linePtsY,linePtsX,2) = 255; %green
            imgPrint(linePtsY,linePtsX,3) = 0; %green

            imgPrint(linePtsY+1,linePtsX,1) = 0; %green
            imgPrint(linePtsY+1,linePtsX,2) = 255; %green
            imgPrint(linePtsY+1,linePtsX,3) = 0; %green

            imgPrint(linePtsY-1,linePtsX,1) = 0; %green
            imgPrint(linePtsY-1,linePtsX,2) = 255; %green
            imgPrint(linePtsY-1,linePtsX,3) = 0; %green
        end
    end



end
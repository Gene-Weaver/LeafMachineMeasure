function LMM_printToConsole(choice,ind,fLen,filename,time)
    
    if choice == "file"
        formatSpec = 'Working on %i / %i --- %s \n';
        fprintf(formatSpec,ind,fLen,filename);
        
    elseif choice == "detect"
        formatSpec = '%s--- Detection: %.2f seconds \n';
        justify = justifyPad(ind,fLen);
        fprintf(formatSpec,justify,time);
        
    elseif choice == "measure"
        formatSpec = '%s--- Measurement: %.2f seconds \n';
        justify = justifyPad(ind,fLen);
        fprintf(formatSpec,justify,time);
    
    elseif choice == "overall"
        formatSpec = 'Processed %i images in %.2f seconds \n';
        fprintf(formatSpec,fLen,time);
        
    elseif choice == "net"
        formatSpec = 'Loading YOLOv2 detection network \n';
        fprintf(formatSpec);
    end
end


function justify = justifyPad(ind,fLen)
    justify = 16 + numel(num2str(ind)) + numel(num2str(fLen)); %16 is length of file printout
    justify = strings(1,justify);
    justify = strjoin(justify);
end
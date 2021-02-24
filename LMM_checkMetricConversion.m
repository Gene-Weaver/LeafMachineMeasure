function [swap,conversion] = LMM_checkMetricConversion(A,B,nB,n)
    conversion = "NA";
    Ain = A;
    Bin = B;

    if A >= B
        swap = 0;
    else 
        A = Bin;
        B = Ain;
        swap = 1;
    end
        
    % mm. to each 
    if Is_A_a_Metric_of_B(A,B,"eq") %1/2
        if nB > 25
            conversion = "equal";
        else
            conversion = "equal";
        end
    elseif Is_A_a_Metric_of_B(A,B,"eq2") %1/2
        if nB + n > 200
            conversion = "1_2mm_to_1mm";
        else
            conversion = "small_tick_half_of_large"; % Designed for rulers that have 0.5mm and 1mm for example
        end
    elseif Is_A_a_Metric_of_B(A,B,"1_2") %1/2
        conversion = "1mm_to_1_2";
    elseif Is_A_a_Metric_of_B(A,B,"1_4")
        conversion = "1mm_to_1_4";
    elseif Is_A_a_Metric_of_B(A,B,"1_8")
        conversion = "1mm_to_1_8";
    elseif Is_A_a_Metric_of_B(A,B,"1_16")
        conversion = "1mm_to_1_16";
    else
        conversion = "NA";
    end
    
    % 1 cm. to each 
    if conversion == "NA"   
        if Is_A_a_Metric_of_B_CM(A,B,"1_2") %1/2
            conversion = "1cm_to_1_2";
        elseif Is_A_a_Metric_of_B_CM(A,B,"1_4")
            conversion = "1cm_to_1_4";
        elseif Is_A_a_Metric_of_B_CM(A,B,"1_8")
            conversion = "1cm_to_1_8";
        elseif Is_A_a_Metric_of_B_CM(A,B,"1_16")
            conversion = "1cm_to_1_16";
        else
            conversion = "NA";
        end
    end
            
%     % Swap places if needed
%     if conversion == "NA"
%         A = B;
%         B = A;
%         swap = 1;
%         if Is_A_a_Metric_of_B(A,B,"1_2") %1/2
%             conversion = "1_2";
%         elseif Is_A_a_Metric_of_B(A,B,"1_4")
%             conversion = "1_4";
%         elseif Is_A_a_Metric_of_B(A,B,"1_8")
%             conversion = "1_8";
%         else
%             conversion = "NA";
%         end
%         
%         if conversion == "NA"
%             if Is_A_a_Metric_of_B_CM(A,B,"1_2") %1/2
%                 conversion = "1cm_to_1_2";
%             elseif Is_A_a_Metric_of_B_CM(A,B,"1_4")
%                 conversion = "1cm_to_1_4";
%             elseif Is_A_a_Metric_of_B_CM(A,B,"1_8")
%                 conversion = "1cm_to_1_8";
%             elseif Is_A_a_Metric_of_B_CM(A,B,"1_16")
%                 conversion = "1cm_to_1_16";
%             else
%                 conversion = "NA";
%             end
%         end
%     end
end

function Y_N = Is_A_a_Metric_of_B(A,B,choice)
    upperBound = 1.03;
    lowerBound = 0.97;
    
    if choice == "eq" %equal 
        C = A / B;
        if ((C <= 1*upperBound) && (C >= 1*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
        
    elseif choice == "eq2" %big is 2x the little
        C = A / B;
        if ((C <= 2*upperBound) && (C >= 2*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
        
    elseif choice == "1_16" %1/16 inch
        C = A / 1.5875;
        if ((C <= B*upperBound) && (C >= B*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
        
    elseif choice == "1_8" %1/8 inch
        C = A / 3.175;
        if ((C <= B*upperBound) && C >= (B*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
        
    elseif choice == "1_4" %1/4 inch
        C = A / 6.35;
        if ((C <= B*upperBound) && (C >= B*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
        
    elseif choice == "1_2" %1/8 inch %%% B and a are swapped since its sorted by descending in check(), this requires the larger value to be the metric number
        C = A / 12.7;
        if ((C <= A*upperBound) && (C >= A*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
    end
    
end

function Y_N = Is_A_a_Metric_of_B_CM(A,B,choice)
    upperBound = 1.03;
    lowerBound = 0.97;
    if choice == "1_16" %1/16 inch
        C = A / 0.15875;
        if ((C <= B*upperBound) && (C >= B*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
        
    elseif choice == "1_8" %1/8 inch
        C = A / 0.3175;
        if ((C <= B*upperBound) && C >= (B*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
        
    elseif choice == "1_4" %1/4 inch
        C = A / 0.635;
        if ((C <= B*upperBound) && (C >= B*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
        
    elseif choice == "1_2" %1/8 inch %%% B and a are swapped since its sorted by descending in check(), this requires the larger value to be the metric number
        C = A / 1.27;
        if ((C <= A*upperBound) && (C >= A*lowerBound))
            Y_N = 1;
        else
            Y_N = 0;
        end
    end
    
end
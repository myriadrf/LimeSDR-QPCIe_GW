module wfm_gen();
    reg clk, reset_n;
    
    initial begin
        clk = 0;
        reset_n = 0;    
    end
    
    always 
        #5 clk =! clk;
        $fopen(i_File_Name, "wb");
        $fwrite(n_File_ID, "%c", r_Frame[i][j]);
    endmodule
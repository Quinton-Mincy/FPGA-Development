module Color_Controller (
  inout iCLK,
  input [17:0] iSW,
  inout reg [15:0] oColor_Walker
);

always @(posedge iCLK) begin
  if (iSW[17]) begin
    	 //red
		oColor_Walker <= 16'hF000;
  end
else if (iSW[16]) begin
	 //coral
		oColor_Walker <= 16'hFAAA;
  end
else if (iSW[15]) begin
	 //yellow
		oColor_Walker <= 16'hFF0F;
  end
  else begin 
	  //white
		oColor_Walker <= 16'hFFFF;
  end
end

endmodule

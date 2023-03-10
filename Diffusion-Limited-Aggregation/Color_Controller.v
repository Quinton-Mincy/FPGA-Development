module Color_Controller (
  inout iCLK,
  input [17:0] iSW,
  inout reg [15:0] oColor_Walker
);

always @(posedge iCLK) begin
  if (iSW[17]) begin
    // RED
		//oLEDR[17] <=1;
		oColor_Walker <= 16'hF000;
  end
  /*
  else if (iSW[16]) begin
    //Pink
		oColor_Walker <= 16'hF0FF;
  end
  else if (iSW[15]) begin
    // yellow
		oColor_Walker <= 16'hFF0F;
  end
  else if (iSW[14]) begin
	 //pale yellow
		oColor_Walker <= 16'hFFAF;
  end
  */
  else if (iSW[13]) begin
	 //coral
		oColor_Walker <= 16'hFAAA;
  end
  else if (iSW[12]) begin
	 //grey
		oColor_Walker <= 16'hAAAA;
  end
  else begin 
		oColor_Walker <= 16'hFFFF;
  end
end

endmodule
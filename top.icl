	Module INS1 {
		DataInPort		temp1[7:0];
		DataOutPort		temp[7:0];
		}
		
        Module INS2 {
		DataInPort		temp1[15:0];
		DataOutPort		temp[15:0];
		}
        Module INS3 {
		DataInPort		temp1[31:0];
		DataOutPort		temp[31:0];
		}
	Module TDR1 {
		ScanInPort		si;
		ScanOutPort		so {	Source	SR[0];
								LaunchEdge	Falling; }
		DataInPort		pi[7:0];
		DataOutPort		po[7:0] {	Source SR; }
								
		SelectPort		en;
		
		ShiftEnPort		se;
		CaptureEnPort	ce;
		UpdateEnPort	ue;
		TCKPort			tck;		
		ScanInterface client     {Port si; Port so;Port en;Port ce;Port se;Port ue;}
		ScanRegister	SR[7:0]{ ScanInSource	si;
								 CaptureSource	pi; }							
		}
	Module TDR2 {
		ScanInPort		si;
		ScanOutPort		so {	Source	SR[0];
								LaunchEdge	Falling; }
		DataInPort		pi[15:0];
		DataOutPort		po[15:0] {	Source SR; }
								
		SelectPort		en;
		
		ShiftEnPort		se;
		CaptureEnPort	ce;
		UpdateEnPort	ue;
		TCKPort			tck;		
		
		ScanRegister	SR[15:0]{ ScanInSource	si;
								 CaptureSource	pi; }							
		}
		
	Module TDR3 {
		ScanInPort		si;
		ScanOutPort		so {	Source	SR[0];
								LaunchEdge	Falling; }
		DataInPort		pi[31:0];
		DataOutPort		po[31:0] {	Source SR; }
								
		SelectPort		en;
		
		ShiftEnPort		se;
		CaptureEnPort	ce;
		UpdateEnPort	ue;
		TCKPort			tck;		
		
		ScanRegister	SR[31:0]{ ScanInSource	si;
								 CaptureSource	pi; }							
		}

	Module SIB {
		ScanInPort		si;
		ScanInPort		fso;
		ScanOutPort		so {	Source	sr;
								LaunchEdge Falling; }
		ScanOutPort		fsi {	Source	si;}
		SelectPort		en;
		ToSelectPort	to_en {	Source	sr;}

		ShiftEnPort		se;
		CaptureEnPort	ce;
		UpdateEnPort	ue;
		TCKPort			tck;		

		ToShiftEnPort	to_se;
		ToCaptureEnPort	to_ce;
		ToUpdateEnPort	to_ue;
		//toTCKPort		to_tck;		
		
		ScanRegister	sr {	ScanInSource	mux1;
								CaptureSource	1'b0;
								ResetValue		1'b0; }
		ScanMux			mux1	SelectedBy	sr {
							1'b0 : si;
							1'b1 : fso;
						}
                ScanInterface client     {Port si; Port so;Port en;Port ce;Port se;Port ue;}
                ScanInterface host    {Port fso;Port fsi;Port to_en;Port to_ce;Port to_se;Port to_ue;}
		}

	Module Chip {
	
		TCKPort tck;
		ScanInPort tdi;
		SelectPort	en_SIB;
		ShiftEnPort		se;
		CaptureEnPort	ce;
		UpdateEnPort	ue;
		ScanOutPort tdo { Source sib3.so; }
		TMSPort tms;
		TRSTPort trst;
		ScanInterface client     {Port tdi; Port tdo;Port en_SIB;Port ce;Port se;Port ue;}
	        Instance TDR_I1 Of TDR1{
		InputPort en = 1;
		InputPort si = tdi;
		InputPort pi = I1.temp;
		}
		Instance I1 Of INS1{
		InputPort		temp1=TDR_I1.po;
		}
		
		Instance sib2 Of SIB {
			InputPort	si = TDR_I1.so;
			InputPort	en = en_SIB;
			InputPort	fso = TDR_I2.so;
			}
		Instance TDR_I2 Of TDR2 {
			InputPort en = sib2.to_en;
			InputPort si = sib2.fsi;
			InputPort pi = I2.temp;
			}
		Instance I2 Of INS2{
		InputPort		temp1=TDR_I2.po;
		}
		

		Instance sib3 Of SIB {
			InputPort	si = sib2.so;
			InputPort	en = en_SIB;
			InputPort	fso = TDR_I3.so;
			}
		Instance TDR_I3 Of TDR3 {
			InputPort en = sib3.to_en;
			InputPort si = sib3.fsi;
			InputPort pi = I3.temp;
			}
		Instance I3 Of INS3{
		InputPort		temp1=TDR_I3.po;
		}			
		
}
Module ChipW {
                Instance c1 Of Chip { }
		AccessLink Tap1 Of STD_1149_1_2001 {
			BSDLEntity SingleInstrumentChip;
                        INTEST { ScanInterface {c1.client;}
                        ActiveSignals {  en_SIB ;}
                        }			
			}
}

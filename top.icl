	Module Sensor {
		DataInPort		en;
		DataOutPort		temp[3:0];
		}

	Module TDR_Sensor {
		ScanInPort		si;
		ScanOutPort		so {	Source	SR[0];
								LaunchEdge	Falling; }
		DataInPort		pi[3:0];
		DataOutPort		po {	Source SR[0]; }
								
		SelectPort		en;
		
		ShiftEnPort		se;
		CaptureEnPort	ce;
		UpdateEnPort	ue;
		TCKPort			tck;		
		
		ScanRegister	SR[3:0]{ ScanInSource	si;
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
		PortGroup		tap_side {si; so; en; ce; se; ue;}
		PortGroup		instrument_side {fso; fsi; to_en; to_ce; to_se; to_ue;}
		}

	Module Chip {
	
		TCKPort tck;
		ScanInPort tdi;
		SelectPort	en_SIB;
		ScanOutPort tdo { Source sib2.so; }
		TMSPort tms;
		TRSTPort trst;
	
		Instance sib1 Of SIB {
			InputPort	si = tdi;
			InputPort	en = en_SIB;
			InputPort	fso = TDR_Sensor_1.so;
			}
		Instance TDR_Sensor_1 Of TDR_Sensor {
			InputPort en = sib1.to_en;
			InputPort si = sib1.fsi;
			InputPort pi = Sensor1.temp;
			}
		Instance Sensor1 Of Sensor {
			InputPort en = TDR_Sensor_1.po;
			}

		Instance sib2 Of SIB {
			InputPort	si = sib1.so;
			InputPort	en = en_SIB;
			InputPort	fso = TDR_Sensor_2.so;
			}
		Instance TDR_Sensor_2 Of TDR_Sensor {
			InputPort en = sib2.to_en;
			InputPort si = sib2.fsi;
			InputPort pi = Sensor2.temp;
			}
		Instance Sensor2 Of Sensor {
			InputPort en = TDR_Sensor_2.po;
			}
						
//		AccessLink Tap1 Of STD_1149_1 {
//			BSDL_Entity Chip;
//			READINSTR { 
//				ScanPath {	sib1; sib2; }
//				ActiveSignals { en_TDR_Sensor ;}
//				}				
//			}
		}
module TOP_PREV (
	input	wire	[31:0]	DI,
	input	wire	[1:0]	ADDR,
	input	wire		WEN,
	output	wire	[31:0]	DO,

	input	wire		CLK,
	input	wire		RSTn
);

	wire	[31:0]	PAD_DI;
	wire	[1:0]	PAD_ADDR;
	wire		PAD_WEN;
	wire	[31:0]	PAD_DO;
	wire		PAD_END;

	wire	[31:0]	CORE_DI;
	wire	[1:0]	CORE_ADDR;
	wire		CORE_WEN;
	wire	[31:0]	CORE_DO;
	wire		CORE_END;


	wire		PAD_CLK;
	wire		PAD_RSTn;

	TOP_CORE top_core_0 (
		.DI(CORE_DI),
		.ADDR(CORE_ADDR),
		.WEN(CORE_WEN),
		.DO(CORE_DO),

		.CLK(PAD_CLK),
		.RSTn(PAD_RSTn)
	);

	
	PipeReg #(32) FF_DI (
		.CLK(PAD_CLK),
		.RST(~PAD_RSTn),
		.EN(1'b1),
		.D(PAD_DI),
		.Q(CORE_DI)
	);

	PipeReg #(2) FF_ADDR (
		.CLK(PAD_CLK),
		.RST(~PAD_RSTn),
		.EN(1'b1),
		.D(PAD_ADDR),
		.Q(CORE_ADDR)
	);

	PipeReg #(1) FF_WEN (
		.CLK(PAD_CLK),
		.RST(~PAD_RSTn),
		.EN(1'b1),
		.D(PAD_WEN),
		.Q(CORE_WEN)
	);

	PipeReg #(32) FF_DO (
		.CLK(PAD_CLK),
		.RST(~PAD_RSTn),
		.EN(1'b1),
		.D(CORE_DO),
		.Q(PAD_DO)
	);



	// input cell
	PBIDIR_18_18_NT_DR pad7 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[0]),   
		.PAD(DI[0]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad8 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[1]),   
		.PAD(DI[1]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad11 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[2]),   
		.PAD(DI[2]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad12 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[3]),   
		.PAD(DI[3]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad15 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[4]),   
		.PAD(DI[4]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad16 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[5]),   
		.PAD(DI[5]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad19 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[6]),   
		.PAD(DI[6]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad20 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[7]),   
		.PAD(DI[7]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad23 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[8]),   
		.PAD(DI[8]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad24 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[9]),   
		.PAD(DI[9]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad27 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[10]),   
		.PAD(DI[10]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad28 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[11]),   
		.PAD(DI[11]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad31 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[12]),   
		.PAD(DI[12]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad32 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[13]),   
		.PAD(DI[13]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad35 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[14]),   
		.PAD(DI[14]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad36 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[15]),   
		.PAD(DI[15]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad43 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[16]),   
		.PAD(DI[16]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad44 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[17]),   
		.PAD(DI[17]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad47 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[18]),   
		.PAD(DI[18]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad48 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[19]),   
		.PAD(DI[19]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad51 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[20]),   
		.PAD(DI[20]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad52 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[21]),   
		.PAD(DI[21]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad55 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[22]),   
		.PAD(DI[22]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad56 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[23]),   
		.PAD(DI[23]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad59 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[24]),   
		.PAD(DI[24]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad60 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[25]),   
		.PAD(DI[25]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad63 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[26]),   
		.PAD(DI[26]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad64 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[27]),   
		.PAD(DI[27]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad67 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[28]),   
		.PAD(DI[28]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad68 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[29]),   
		.PAD(DI[29]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad71 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[30]),   
		.PAD(DI[30]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad72 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_DI[31]),   
		.PAD(DI[31]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad75 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_CLK),   
		.PAD(CLK), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad76 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_RSTn),   
		.PAD(RSTn), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad83 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[0]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[0]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad84 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[1]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[1]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad87 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[2]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[2]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad88 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[3]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[3]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad91 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[4]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[4]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad92 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[5]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[5]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad95 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[6]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[6]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad96 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[7]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[7]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad99 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[8]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[8]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad100 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[9]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[9]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad103 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[10]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[10]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad104 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[11]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[11]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad107 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[12]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[12]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad108 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[13]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[13]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad111 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[14]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[14]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad112 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[15]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[15]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad115 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[16]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[16]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad116 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[17]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[17]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad123 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[18]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[18]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad124 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[19]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[19]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad127 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[20]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[20]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad128 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[21]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[21]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad131 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[22]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[22]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad132 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[23]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[23]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad135 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[24]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[24]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad136 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[25]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[25]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad139 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[26]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[26]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad140 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[27]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[27]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad143 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[28]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[28]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad144 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[29]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[29]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// output cell
	PBIDIR_18_18_NT_DR pad147 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[30]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[30]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// output cell
	PBIDIR_18_18_NT_DR pad148 ( 
		.POE(1'b1),		// just 1
		.PO(),			// POE is 1 and this value is ~Y, no use and not connect : this is output cell
		.IE(1'b0),		// Input Enable
		.IS(1'b1),		// 1 is Schmitt Input but this time, this is output, so never mind
		.Y(),			// this is output so no connect 
		.PAD(DO[31]),	
		.OE(1'b1),		// Output Enable
		.A(PAD_DO[31]),     
		.DS0(1'b1),		// Drive select 0 : DS0 and DS1 are 2'b11, Output PAD driving is 12mA and 200MHz capable
		.DS1(1'b1),		// Drive select 1 
		.SR(1'b0),		// Slew Rate : 0 makes fast slew rates, 1 makes slow slew rates
		.PE(1'b1),		// Pull Enable 	
		.PS(1'b0),		// Pull Down signal : CLK_GATED
		.RTO(1'b1),
		.SNS(1'b1)
	);	

	// input cell
	PBIDIR_18_18_NT_DR pad151 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_ADDR[0]),   
		.PAD(ADDR[0]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad152 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_ADDR[1]),   
		.PAD(ADDR[1]), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);

	// input cell
	PBIDIR_18_18_NT_DR pad156 ( 
		.POE(1'b1), 	// just 1
		.PO(),      	// POE is 1 and this value is ~Y, no use and not connect even though this is input cell
		.IE(1'b1), 	// Input Enable
		.IS(1'b1),  	// Schmitt Input
		.Y(PAD_WEN),   
		.PAD(WEN), 
		.OE(1'b0), 	// Output Enable
		.A(1'b0),  	// no use in case of INPUT 
		.DS0(1'b0), 	// no use in case of INPUT 
		.DS1(1'b0), 	// no use in case of INPUT 
		.SR(1'b0),   	// no use in case of INPUT 
		.PE(1'b1),  	// Pull Enable 
		.PS(1'b1),  	// Pull Up signal : HRESETn
		.RTO(1'b1),
		.SNS(1'b1)
	);


endmodule


module TOP_CORE (
	input	wire	[31:0]	DI,
	input	wire	[1:0]	ADDR,
	input	wire		WEN,
	output	wire	[31:0]	DO,

	input	wire		CLK,
	input	wire		RSTn
);


	// CORE

	wire	[31:0]	CORE_IMEM_DO;
	wire	[13:0]	CORE_IMEM_ADDR;
	wire		CORE_IMEM_CSN;
	wire		CORE_IMEM_WEN;

	wire	[31:0]	CORE_DMEM_DI;
	wire	[31:0]	CORE_DMEM_DO;
	wire	[14:0]	CORE_DMEM_ADDR;
	wire	[31:0]	CORE_DMEM_BE;
	wire	[63:0]	CORE_DMEM_CSN;
	wire		CORE_DMEM_WEN;

	wire		CORE_MEMSET_SEL_MODE;
	wire		CORE_MEMSET_SEL_PREC;
	wire	[2:0]	CORE_MEMSET_SEL_BLOCK;

	wire	[7:0]	CORE_VECTOR_EN;
	wire	[7:0]	CORE_VECTOR_LOAD_EN;
	
	wire		CORE_VECTOR_EN_DI_0_0;
	wire		CORE_VECTOR_EN_DI_0_1;
	wire		CORE_VECTOR_EN_DI_1_0;
	wire		CORE_VECTOR_EN_DI_1_1;
	wire		CORE_VECTOR_EN_DO_0_0;
	wire		CORE_VECTOR_EN_DO_0_1;
	wire		CORE_VECTOR_LOAD_TYPE;

	wire		CORE_VECTOR_SEL_DI_0_R;
	wire		CORE_VECTOR_SEL_DI_1_R;
	wire		CORE_VECTOR_SEL_DO_0_R;
	wire		CORE_VECTOR_SEL_DO_0_W;
	wire		CORE_VECTOR_SEL_DO_SUM;

	wire	[1:0]	CORE_VECTOR_SEL_OP;
	wire		CORE_VECTOR_SEL_PREC;

	wire	[1:0]	CORE_VECTOR_MODE;

	wire		CORE_CORE_EN;
	wire		CORE_END;

	CORE core_0 (
		.IMEM_DO(CORE_IMEM_DO),
		.IMEM_ADDR(CORE_IMEM_ADDR),
		.IMEM_CSN(CORE_IMEM_CSN),
		.IMEM_WEN(CORE_IMEM_WEN),

		.DMEM_DI(CORE_DMEM_DI),
		.DMEM_DO(CORE_DMEM_DO),
		.DMEM_ADDR(CORE_DMEM_ADDR),
		.DMEM_BE(CORE_DMEM_BE),
		.DMEM_CSN(CORE_DMEM_CSN),
		.DMEM_WEN(CORE_DMEM_WEN),

		.MEMSET_SEL_MODE(CORE_MEMSET_SEL_MODE),
		.MEMSET_SEL_PREC(CORE_MEMSET_SEL_PREC),
		.MEMSET_SEL_BLOCK(CORE_MEMSET_SEL_BLOCK),

		.VECTOR_EN(CORE_VECTOR_EN),
		.VECTOR_LOAD_EN(CORE_VECTOR_LOAD_EN),
		
		.VECTOR_EN_DI_0_0(CORE_VECTOR_EN_DI_0_0),
		.VECTOR_EN_DI_0_1(CORE_VECTOR_EN_DI_0_1),
		.VECTOR_EN_DI_1_0(CORE_VECTOR_EN_DI_1_0),
		.VECTOR_EN_DI_1_1(CORE_VECTOR_EN_DI_1_1),
		.VECTOR_EN_DO_0_0(CORE_VECTOR_EN_DO_0_0),
		.VECTOR_EN_DO_0_1(CORE_VECTOR_EN_DO_0_1),
		.VECTOR_LOAD_TYPE(CORE_VECTOR_LOAD_TYPE),

		.VECTOR_SEL_DI_0_R(CORE_VECTOR_SEL_DI_0_R),
		.VECTOR_SEL_DI_1_R(CORE_VECTOR_SEL_DI_1_R),
		.VECTOR_SEL_DO_0_R(CORE_VECTOR_SEL_DO_0_R),
		.VECTOR_SEL_DO_0_W(CORE_VECTOR_SEL_DO_0_W),
		.VECTOR_SEL_DO_SUM(CORE_VECTOR_SEL_DO_SUM),

		.VECTOR_SEL_OP(CORE_VECTOR_SEL_OP),
		.VECTOR_SEL_PREC(CORE_VECTOR_SEL_PREC),

		.VECTOR_MODE(CORE_VECTOR_MODE),

		.CORE_EN(CORE_CORE_EN),
		.END(CORE_END),
		.CLK(CLK),
		.RSTn(RSTn)
	);

	
	wire		FF_CORE_EN_D, FF_CORE_EN_Q;
	
	PipeReg #(1) FF_CORE_EN (
		.CLK(CLK),
		.RST(~RSTn),
		.EN(1'b1),
		.D(FF_CORE_EN_D),
		.Q(FF_CORE_EN_Q));

	assign	FF_CORE_EN_D	=	((ADDR == 2'b00) & ~WEN)	? DI[0] :
					FF_CORE_EN_Q;
	assign	CORE_CORE_EN	=	FF_CORE_EN_Q;

	wire		FF_CORE_END_D, FF_CORE_END_Q;

	PipeReg #(1) FF_CORE_END (
		.CLK(CLK),
		.RST(~RSTn),
		.EN(1'b1),
		.D(FF_CORE_END_D),
		.Q(FF_CORE_END_Q));

	assign	FF_CORE_END_D	=	CORE_END;

	
	// IMEM
	
	wire	[31:0]	IMEM_DI;
	wire	[11:0]	IMEM_ADDR;
	wire		IMEM_CSN;
	wire		IMEM_WEN;
	wire	[31:0]	IMEM_DO;

	IMEM imem_0 (
		.DI(IMEM_DI),
		.ADDR(IMEM_ADDR),
		.CSN(IMEM_CSN),
		.WEN(IMEM_WEN),
		.DO(IMEM_DO),

		.CLK(CLK),
		.RSTn(RSTn)
	);

	wire	[11:0]	FF_IMEM_INIT_CNT_D, FF_IMEM_INIT_CNT_Q;

	PipeReg #(12) FF_IMEM_INIT_CNT (
		.CLK(CLK),
		.RST(~RSTn),
		.EN(1'b1),
		.D(FF_IMEM_INIT_CNT_D),
		.Q(FF_IMEM_INIT_CNT_Q));

	assign	FF_IMEM_INIT_CNT_D	=	((ADDR == 2'b01) & ~WEN)	? FF_IMEM_INIT_CNT_Q + 12'd1 :
						12'd0;


	assign	IMEM_DI		=	DI;
	assign	IMEM_ADDR	=	((ADDR == 2'b01) & ~WEN)	? FF_IMEM_INIT_CNT_Q :
					CORE_IMEM_ADDR[13:2];
	assign	IMEM_CSN	=	((ADDR == 2'b01) & ~WEN)	? 1'b0 :
					CORE_IMEM_CSN;
	assign	IMEM_WEN	=	((ADDR == 2'b01) & ~WEN)	? 1'b0 :
					CORE_IMEM_WEN;
	assign	CORE_IMEM_DO	=	IMEM_DO;


	// VECTOR

	wire	[31:0]	VECTOR_0_DI_0_00;
	wire	[31:0]	VECTOR_0_DI_0_01;
	wire	[31:0]	VECTOR_0_DI_0_02;
	wire	[31:0]	VECTOR_0_DI_0_03;
	wire	[31:0]	VECTOR_0_DI_0_04;
	wire	[31:0]	VECTOR_0_DI_0_05;
	wire	[31:0]	VECTOR_0_DI_0_06;
	wire	[31:0]	VECTOR_0_DI_0_07;
	wire	[31:0]	VECTOR_0_DI_0_08;
	wire	[31:0]	VECTOR_0_DI_0_09;
	wire	[31:0]	VECTOR_0_DI_0_10;
	wire	[31:0]	VECTOR_0_DI_0_11;
	wire	[31:0]	VECTOR_0_DI_0_12;
	wire	[31:0]	VECTOR_0_DI_0_13;
	wire	[31:0]	VECTOR_0_DI_0_14;
	wire	[31:0]	VECTOR_0_DI_0_15;
	wire	[31:0]	VECTOR_0_DI_0_16;
	wire	[31:0]	VECTOR_0_DI_0_17;
	wire	[31:0]	VECTOR_0_DI_0_18;
	wire	[31:0]	VECTOR_0_DI_0_19;
	wire	[31:0]	VECTOR_0_DI_0_20;
	wire	[31:0]	VECTOR_0_DI_0_21;
	wire	[31:0]	VECTOR_0_DI_0_22;
	wire	[31:0]	VECTOR_0_DI_0_23;
	wire	[31:0]	VECTOR_0_DI_0_24;
	wire	[31:0]	VECTOR_0_DI_0_25;
	wire	[31:0]	VECTOR_0_DI_0_26;
	wire	[31:0]	VECTOR_0_DI_0_27;
	wire	[31:0]	VECTOR_0_DI_0_28;
	wire	[31:0]	VECTOR_0_DI_0_29;
	wire	[31:0]	VECTOR_0_DI_0_30;
	wire	[31:0]	VECTOR_0_DI_0_31;
	wire	[31:0]	VECTOR_0_DI_0_32;
	wire	[31:0]	VECTOR_0_DI_0_33;
	wire	[31:0]	VECTOR_0_DI_0_34;
	wire	[31:0]	VECTOR_0_DI_0_35;
	wire	[31:0]	VECTOR_0_DI_0_36;
	wire	[31:0]	VECTOR_0_DI_0_37;
	wire	[31:0]	VECTOR_0_DI_0_38;
	wire	[31:0]	VECTOR_0_DI_0_39;
	wire	[31:0]	VECTOR_0_DI_0_40;
	wire	[31:0]	VECTOR_0_DI_0_41;
	wire	[31:0]	VECTOR_0_DI_0_42;
	wire	[31:0]	VECTOR_0_DI_0_43;
	wire	[31:0]	VECTOR_0_DI_0_44;
	wire	[31:0]	VECTOR_0_DI_0_45;
	wire	[31:0]	VECTOR_0_DI_0_46;
	wire	[31:0]	VECTOR_0_DI_0_47;
	wire	[31:0]	VECTOR_0_DI_0_48;
	wire	[31:0]	VECTOR_0_DI_0_49;
	wire	[31:0]	VECTOR_0_DI_0_50;
	wire	[31:0]	VECTOR_0_DI_0_51;
	wire	[31:0]	VECTOR_0_DI_0_52;
	wire	[31:0]	VECTOR_0_DI_0_53;
	wire	[31:0]	VECTOR_0_DI_0_54;
	wire	[31:0]	VECTOR_0_DI_0_55;
	wire	[31:0]	VECTOR_0_DI_0_56;
	wire	[31:0]	VECTOR_0_DI_0_57;
	wire	[31:0]	VECTOR_0_DI_0_58;
	wire	[31:0]	VECTOR_0_DI_0_59;
	wire	[31:0]	VECTOR_0_DI_0_60;
	wire	[31:0]	VECTOR_0_DI_0_61;
	wire	[31:0]	VECTOR_0_DI_0_62;
	wire	[31:0]	VECTOR_0_DI_0_63;
	
	wire	[31:0]	VECTOR_0_DO_0_00;
	wire	[31:0]	VECTOR_0_DO_0_01;
	wire	[31:0]	VECTOR_0_DO_0_02;
	wire	[31:0]	VECTOR_0_DO_0_03;
	wire	[31:0]	VECTOR_0_DO_0_04;
	wire	[31:0]	VECTOR_0_DO_0_05;
	wire	[31:0]	VECTOR_0_DO_0_06;
	wire	[31:0]	VECTOR_0_DO_0_07;
	wire	[31:0]	VECTOR_0_DO_0_08;
	wire	[31:0]	VECTOR_0_DO_0_09;
	wire	[31:0]	VECTOR_0_DO_0_10;
	wire	[31:0]	VECTOR_0_DO_0_11;
	wire	[31:0]	VECTOR_0_DO_0_12;
	wire	[31:0]	VECTOR_0_DO_0_13;
	wire	[31:0]	VECTOR_0_DO_0_14;
	wire	[31:0]	VECTOR_0_DO_0_15;
	wire	[31:0]	VECTOR_0_DO_0_16;
	wire	[31:0]	VECTOR_0_DO_0_17;
	wire	[31:0]	VECTOR_0_DO_0_18;
	wire	[31:0]	VECTOR_0_DO_0_19;
	wire	[31:0]	VECTOR_0_DO_0_20;
	wire	[31:0]	VECTOR_0_DO_0_21;
	wire	[31:0]	VECTOR_0_DO_0_22;
	wire	[31:0]	VECTOR_0_DO_0_23;
	wire	[31:0]	VECTOR_0_DO_0_24;
	wire	[31:0]	VECTOR_0_DO_0_25;
	wire	[31:0]	VECTOR_0_DO_0_26;
	wire	[31:0]	VECTOR_0_DO_0_27;
	wire	[31:0]	VECTOR_0_DO_0_28;
	wire	[31:0]	VECTOR_0_DO_0_29;
	wire	[31:0]	VECTOR_0_DO_0_30;
	wire	[31:0]	VECTOR_0_DO_0_31;
	wire	[31:0]	VECTOR_0_DO_0_32;
	wire	[31:0]	VECTOR_0_DO_0_33;
	wire	[31:0]	VECTOR_0_DO_0_34;
	wire	[31:0]	VECTOR_0_DO_0_35;
	wire	[31:0]	VECTOR_0_DO_0_36;
	wire	[31:0]	VECTOR_0_DO_0_37;
	wire	[31:0]	VECTOR_0_DO_0_38;
	wire	[31:0]	VECTOR_0_DO_0_39;
	wire	[31:0]	VECTOR_0_DO_0_40;
	wire	[31:0]	VECTOR_0_DO_0_41;
	wire	[31:0]	VECTOR_0_DO_0_42;
	wire	[31:0]	VECTOR_0_DO_0_43;
	wire	[31:0]	VECTOR_0_DO_0_44;
	wire	[31:0]	VECTOR_0_DO_0_45;
	wire	[31:0]	VECTOR_0_DO_0_46;
	wire	[31:0]	VECTOR_0_DO_0_47;
	wire	[31:0]	VECTOR_0_DO_0_48;
	wire	[31:0]	VECTOR_0_DO_0_49;
	wire	[31:0]	VECTOR_0_DO_0_50;
	wire	[31:0]	VECTOR_0_DO_0_51;
	wire	[31:0]	VECTOR_0_DO_0_52;
	wire	[31:0]	VECTOR_0_DO_0_53;
	wire	[31:0]	VECTOR_0_DO_0_54;
	wire	[31:0]	VECTOR_0_DO_0_55;
	wire	[31:0]	VECTOR_0_DO_0_56;
	wire	[31:0]	VECTOR_0_DO_0_57;
	wire	[31:0]	VECTOR_0_DO_0_58;
	wire	[31:0]	VECTOR_0_DO_0_59;
	wire	[31:0]	VECTOR_0_DO_0_60;
	wire	[31:0]	VECTOR_0_DO_0_61;
	wire	[31:0]	VECTOR_0_DO_0_62;
	wire	[31:0]	VECTOR_0_DO_0_63;

	wire	[31:0]	VECTOR_0_DO_SUM;

	wire		VECTOR_0_EN_DI_0_0;
	wire		VECTOR_0_EN_DI_0_1;
	wire		VECTOR_0_EN_DI_1_0;
	wire		VECTOR_0_EN_DI_1_1;
	wire		VECTOR_0_EN_DO_0_0;
	wire		VECTOR_0_EN_DO_0_1;

	wire		VECTOR_0_SEL_DI_0_R;
	wire		VECTOR_0_SEL_DI_1_R;
	wire		VECTOR_0_SEL_DO_0_R;
	wire		VECTOR_0_SEL_DO_0_W;
	wire		VECTOR_0_SEL_DO_SUM_PREC;

	wire	[1:0]	VECTOR_0_SEL_OP;
	wire		VECTOR_0_SEL_PREC;
	wire	[2:0]	VECTOR_0_SEL_BLOCK_LOAD;
	
	wire		VECTOR_0_VECTOR_EN;
	wire		VECTOR_0_VECTOR_LOAD_EN;
	wire	[1:0]	VECTOR_0_VECTOR_MODE;	
	
	VECTOR vector_0 (
		.DI_0_00(VECTOR_0_DI_0_00),	
		.DI_0_01(VECTOR_0_DI_0_01),	
		.DI_0_02(VECTOR_0_DI_0_02),	
		.DI_0_03(VECTOR_0_DI_0_03),	
		.DI_0_04(VECTOR_0_DI_0_04),	
		.DI_0_05(VECTOR_0_DI_0_05),	
		.DI_0_06(VECTOR_0_DI_0_06),	
		.DI_0_07(VECTOR_0_DI_0_07),	
		.DI_0_08(VECTOR_0_DI_0_08),	
		.DI_0_09(VECTOR_0_DI_0_09),	
		.DI_0_10(VECTOR_0_DI_0_10),	
		.DI_0_11(VECTOR_0_DI_0_11),	
		.DI_0_12(VECTOR_0_DI_0_12),	
		.DI_0_13(VECTOR_0_DI_0_13),	
		.DI_0_14(VECTOR_0_DI_0_14),	
		.DI_0_15(VECTOR_0_DI_0_15),	
		.DI_0_16(VECTOR_0_DI_0_16),	
		.DI_0_17(VECTOR_0_DI_0_17),	
		.DI_0_18(VECTOR_0_DI_0_18),	
		.DI_0_19(VECTOR_0_DI_0_19),	
		.DI_0_20(VECTOR_0_DI_0_20),	
		.DI_0_21(VECTOR_0_DI_0_21),	
		.DI_0_22(VECTOR_0_DI_0_22),	
		.DI_0_23(VECTOR_0_DI_0_23),	
		.DI_0_24(VECTOR_0_DI_0_24),	
		.DI_0_25(VECTOR_0_DI_0_25),	
		.DI_0_26(VECTOR_0_DI_0_26),	
		.DI_0_27(VECTOR_0_DI_0_27),	
		.DI_0_28(VECTOR_0_DI_0_28),	
		.DI_0_29(VECTOR_0_DI_0_29),	
		.DI_0_30(VECTOR_0_DI_0_30),	
		.DI_0_31(VECTOR_0_DI_0_31),	
		.DI_0_32(VECTOR_0_DI_0_32),	
		.DI_0_33(VECTOR_0_DI_0_33),	
		.DI_0_34(VECTOR_0_DI_0_34),	
		.DI_0_35(VECTOR_0_DI_0_35),	
		.DI_0_36(VECTOR_0_DI_0_36),	
		.DI_0_37(VECTOR_0_DI_0_37),	
		.DI_0_38(VECTOR_0_DI_0_38),	
		.DI_0_39(VECTOR_0_DI_0_39),	
		.DI_0_40(VECTOR_0_DI_0_40),	
		.DI_0_41(VECTOR_0_DI_0_41),	
		.DI_0_42(VECTOR_0_DI_0_42),	
		.DI_0_43(VECTOR_0_DI_0_43),	
		.DI_0_44(VECTOR_0_DI_0_44),	
		.DI_0_45(VECTOR_0_DI_0_45),	
		.DI_0_46(VECTOR_0_DI_0_46),	
		.DI_0_47(VECTOR_0_DI_0_47),	
		.DI_0_48(VECTOR_0_DI_0_48),	
		.DI_0_49(VECTOR_0_DI_0_49),	
		.DI_0_50(VECTOR_0_DI_0_50),	
		.DI_0_51(VECTOR_0_DI_0_51),	
		.DI_0_52(VECTOR_0_DI_0_52),	
		.DI_0_53(VECTOR_0_DI_0_53),	
		.DI_0_54(VECTOR_0_DI_0_54),	
		.DI_0_55(VECTOR_0_DI_0_55),	
		.DI_0_56(VECTOR_0_DI_0_56),	
		.DI_0_57(VECTOR_0_DI_0_57),	
		.DI_0_58(VECTOR_0_DI_0_58),	
		.DI_0_59(VECTOR_0_DI_0_59),	
		.DI_0_60(VECTOR_0_DI_0_60),	
		.DI_0_61(VECTOR_0_DI_0_61),	
		.DI_0_62(VECTOR_0_DI_0_62),	
		.DI_0_63(VECTOR_0_DI_0_63),	
		
		.DO_0_00(VECTOR_0_DO_0_00),	
		.DO_0_01(VECTOR_0_DO_0_01),	
		.DO_0_02(VECTOR_0_DO_0_02),	
		.DO_0_03(VECTOR_0_DO_0_03),	
		.DO_0_04(VECTOR_0_DO_0_04),	
		.DO_0_05(VECTOR_0_DO_0_05),	
		.DO_0_06(VECTOR_0_DO_0_06),	
		.DO_0_07(VECTOR_0_DO_0_07),	
		.DO_0_08(VECTOR_0_DO_0_08),	
		.DO_0_09(VECTOR_0_DO_0_09),	
		.DO_0_10(VECTOR_0_DO_0_10),	
		.DO_0_11(VECTOR_0_DO_0_11),	
		.DO_0_12(VECTOR_0_DO_0_12),	
		.DO_0_13(VECTOR_0_DO_0_13),	
		.DO_0_14(VECTOR_0_DO_0_14),	
		.DO_0_15(VECTOR_0_DO_0_15),	
		.DO_0_16(VECTOR_0_DO_0_16),	
		.DO_0_17(VECTOR_0_DO_0_17),	
		.DO_0_18(VECTOR_0_DO_0_18),	
		.DO_0_19(VECTOR_0_DO_0_19),	
		.DO_0_20(VECTOR_0_DO_0_20),	
		.DO_0_21(VECTOR_0_DO_0_21),	
		.DO_0_22(VECTOR_0_DO_0_22),	
		.DO_0_23(VECTOR_0_DO_0_23),	
		.DO_0_24(VECTOR_0_DO_0_24),	
		.DO_0_25(VECTOR_0_DO_0_25),	
		.DO_0_26(VECTOR_0_DO_0_26),	
		.DO_0_27(VECTOR_0_DO_0_27),	
		.DO_0_28(VECTOR_0_DO_0_28),	
		.DO_0_29(VECTOR_0_DO_0_29),	
		.DO_0_30(VECTOR_0_DO_0_30),	
		.DO_0_31(VECTOR_0_DO_0_31),	
		.DO_0_32(VECTOR_0_DO_0_32),	
		.DO_0_33(VECTOR_0_DO_0_33),	
		.DO_0_34(VECTOR_0_DO_0_34),	
		.DO_0_35(VECTOR_0_DO_0_35),	
		.DO_0_36(VECTOR_0_DO_0_36),	
		.DO_0_37(VECTOR_0_DO_0_37),	
		.DO_0_38(VECTOR_0_DO_0_38),	
		.DO_0_39(VECTOR_0_DO_0_39),	
		.DO_0_40(VECTOR_0_DO_0_40),	
		.DO_0_41(VECTOR_0_DO_0_41),	
		.DO_0_42(VECTOR_0_DO_0_42),	
		.DO_0_43(VECTOR_0_DO_0_43),	
		.DO_0_44(VECTOR_0_DO_0_44),	
		.DO_0_45(VECTOR_0_DO_0_45),	
		.DO_0_46(VECTOR_0_DO_0_46),	
		.DO_0_47(VECTOR_0_DO_0_47),	
		.DO_0_48(VECTOR_0_DO_0_48),	
		.DO_0_49(VECTOR_0_DO_0_49),	
		.DO_0_50(VECTOR_0_DO_0_50),	
		.DO_0_51(VECTOR_0_DO_0_51),	
		.DO_0_52(VECTOR_0_DO_0_52),	
		.DO_0_53(VECTOR_0_DO_0_53),	
		.DO_0_54(VECTOR_0_DO_0_54),	
		.DO_0_55(VECTOR_0_DO_0_55),	
		.DO_0_56(VECTOR_0_DO_0_56),	
		.DO_0_57(VECTOR_0_DO_0_57),	
		.DO_0_58(VECTOR_0_DO_0_58),	
		.DO_0_59(VECTOR_0_DO_0_59),	
		.DO_0_60(VECTOR_0_DO_0_60),	
		.DO_0_61(VECTOR_0_DO_0_61),	
		.DO_0_62(VECTOR_0_DO_0_62),	
		.DO_0_63(VECTOR_0_DO_0_63),

		.DO_SUM(VECTOR_0_DO_SUM),

		.EN_DI_0_0(VECTOR_0_EN_DI_0_0),
		.EN_DI_0_1(VECTOR_0_EN_DI_0_1),
		.EN_DI_1_0(VECTOR_0_EN_DI_1_0),
		.EN_DI_1_1(VECTOR_0_EN_DI_1_1),
		.EN_DO_0_0(VECTOR_0_EN_DO_0_0),
		.EN_DO_0_1(VECTOR_0_EN_DO_0_1),

		.SEL_DI_0_R(VECTOR_0_SEL_DI_0_R),
		.SEL_DI_1_R(VECTOR_0_SEL_DI_1_R),
		.SEL_DO_0_R(VECTOR_0_SEL_DO_0_R),
		.SEL_DO_0_W(VECTOR_0_SEL_DO_0_W),
		.SEL_DO_SUM_PREC(VECTOR_0_SEL_DO_SUM_PREC),

		.SEL_OP(VECTOR_0_SEL_OP),
		.SEL_PREC(VECTOR_0_SEL_PREC),
		.SEL_BLOCK_LOAD(VECTOR_0_SEL_BLOCK_LOAD),

		.VECTOR_EN(VECTOR_0_VECTOR_EN),
		.VECTOR_LOAD_EN(VECTOR_0_VECTOR_LOAD_EN),
		.VECTOR_MODE(VECTOR_0_VECTOR_MODE),

		.CLK(CLK),
		.RSTn(RSTn)
	);




	wire	[31:0]	VECTOR_1_DI_0_00;
	wire	[31:0]	VECTOR_1_DI_0_01;
	wire	[31:0]	VECTOR_1_DI_0_02;
	wire	[31:0]	VECTOR_1_DI_0_03;
	wire	[31:0]	VECTOR_1_DI_0_04;
	wire	[31:0]	VECTOR_1_DI_0_05;
	wire	[31:0]	VECTOR_1_DI_0_06;
	wire	[31:0]	VECTOR_1_DI_0_07;
	wire	[31:0]	VECTOR_1_DI_0_08;
	wire	[31:0]	VECTOR_1_DI_0_09;
	wire	[31:0]	VECTOR_1_DI_0_10;
	wire	[31:0]	VECTOR_1_DI_0_11;
	wire	[31:0]	VECTOR_1_DI_0_12;
	wire	[31:0]	VECTOR_1_DI_0_13;
	wire	[31:0]	VECTOR_1_DI_0_14;
	wire	[31:0]	VECTOR_1_DI_0_15;
	wire	[31:0]	VECTOR_1_DI_0_16;
	wire	[31:0]	VECTOR_1_DI_0_17;
	wire	[31:0]	VECTOR_1_DI_0_18;
	wire	[31:0]	VECTOR_1_DI_0_19;
	wire	[31:0]	VECTOR_1_DI_0_20;
	wire	[31:0]	VECTOR_1_DI_0_21;
	wire	[31:0]	VECTOR_1_DI_0_22;
	wire	[31:0]	VECTOR_1_DI_0_23;
	wire	[31:0]	VECTOR_1_DI_0_24;
	wire	[31:0]	VECTOR_1_DI_0_25;
	wire	[31:0]	VECTOR_1_DI_0_26;
	wire	[31:0]	VECTOR_1_DI_0_27;
	wire	[31:0]	VECTOR_1_DI_0_28;
	wire	[31:0]	VECTOR_1_DI_0_29;
	wire	[31:0]	VECTOR_1_DI_0_30;
	wire	[31:0]	VECTOR_1_DI_0_31;
	wire	[31:0]	VECTOR_1_DI_0_32;
	wire	[31:0]	VECTOR_1_DI_0_33;
	wire	[31:0]	VECTOR_1_DI_0_34;
	wire	[31:0]	VECTOR_1_DI_0_35;
	wire	[31:0]	VECTOR_1_DI_0_36;
	wire	[31:0]	VECTOR_1_DI_0_37;
	wire	[31:0]	VECTOR_1_DI_0_38;
	wire	[31:0]	VECTOR_1_DI_0_39;
	wire	[31:0]	VECTOR_1_DI_0_40;
	wire	[31:0]	VECTOR_1_DI_0_41;
	wire	[31:0]	VECTOR_1_DI_0_42;
	wire	[31:0]	VECTOR_1_DI_0_43;
	wire	[31:0]	VECTOR_1_DI_0_44;
	wire	[31:0]	VECTOR_1_DI_0_45;
	wire	[31:0]	VECTOR_1_DI_0_46;
	wire	[31:0]	VECTOR_1_DI_0_47;
	wire	[31:0]	VECTOR_1_DI_0_48;
	wire	[31:0]	VECTOR_1_DI_0_49;
	wire	[31:0]	VECTOR_1_DI_0_50;
	wire	[31:0]	VECTOR_1_DI_0_51;
	wire	[31:0]	VECTOR_1_DI_0_52;
	wire	[31:0]	VECTOR_1_DI_0_53;
	wire	[31:0]	VECTOR_1_DI_0_54;
	wire	[31:0]	VECTOR_1_DI_0_55;
	wire	[31:0]	VECTOR_1_DI_0_56;
	wire	[31:0]	VECTOR_1_DI_0_57;
	wire	[31:0]	VECTOR_1_DI_0_58;
	wire	[31:0]	VECTOR_1_DI_0_59;
	wire	[31:0]	VECTOR_1_DI_0_60;
	wire	[31:0]	VECTOR_1_DI_0_61;
	wire	[31:0]	VECTOR_1_DI_0_62;
	wire	[31:0]	VECTOR_1_DI_0_63;
	
	wire	[31:0]	VECTOR_1_DO_0_00;
	wire	[31:0]	VECTOR_1_DO_0_01;
	wire	[31:0]	VECTOR_1_DO_0_02;
	wire	[31:0]	VECTOR_1_DO_0_03;
	wire	[31:0]	VECTOR_1_DO_0_04;
	wire	[31:0]	VECTOR_1_DO_0_05;
	wire	[31:0]	VECTOR_1_DO_0_06;
	wire	[31:0]	VECTOR_1_DO_0_07;
	wire	[31:0]	VECTOR_1_DO_0_08;
	wire	[31:0]	VECTOR_1_DO_0_09;
	wire	[31:0]	VECTOR_1_DO_0_10;
	wire	[31:0]	VECTOR_1_DO_0_11;
	wire	[31:0]	VECTOR_1_DO_0_12;
	wire	[31:0]	VECTOR_1_DO_0_13;
	wire	[31:0]	VECTOR_1_DO_0_14;
	wire	[31:0]	VECTOR_1_DO_0_15;
	wire	[31:0]	VECTOR_1_DO_0_16;
	wire	[31:0]	VECTOR_1_DO_0_17;
	wire	[31:0]	VECTOR_1_DO_0_18;
	wire	[31:0]	VECTOR_1_DO_0_19;
	wire	[31:0]	VECTOR_1_DO_0_20;
	wire	[31:0]	VECTOR_1_DO_0_21;
	wire	[31:0]	VECTOR_1_DO_0_22;
	wire	[31:0]	VECTOR_1_DO_0_23;
	wire	[31:0]	VECTOR_1_DO_0_24;
	wire	[31:0]	VECTOR_1_DO_0_25;
	wire	[31:0]	VECTOR_1_DO_0_26;
	wire	[31:0]	VECTOR_1_DO_0_27;
	wire	[31:0]	VECTOR_1_DO_0_28;
	wire	[31:0]	VECTOR_1_DO_0_29;
	wire	[31:0]	VECTOR_1_DO_0_30;
	wire	[31:0]	VECTOR_1_DO_0_31;
	wire	[31:0]	VECTOR_1_DO_0_32;
	wire	[31:0]	VECTOR_1_DO_0_33;
	wire	[31:0]	VECTOR_1_DO_0_34;
	wire	[31:0]	VECTOR_1_DO_0_35;
	wire	[31:0]	VECTOR_1_DO_0_36;
	wire	[31:0]	VECTOR_1_DO_0_37;
	wire	[31:0]	VECTOR_1_DO_0_38;
	wire	[31:0]	VECTOR_1_DO_0_39;
	wire	[31:0]	VECTOR_1_DO_0_40;
	wire	[31:0]	VECTOR_1_DO_0_41;
	wire	[31:0]	VECTOR_1_DO_0_42;
	wire	[31:0]	VECTOR_1_DO_0_43;
	wire	[31:0]	VECTOR_1_DO_0_44;
	wire	[31:0]	VECTOR_1_DO_0_45;
	wire	[31:0]	VECTOR_1_DO_0_46;
	wire	[31:0]	VECTOR_1_DO_0_47;
	wire	[31:0]	VECTOR_1_DO_0_48;
	wire	[31:0]	VECTOR_1_DO_0_49;
	wire	[31:0]	VECTOR_1_DO_0_50;
	wire	[31:0]	VECTOR_1_DO_0_51;
	wire	[31:0]	VECTOR_1_DO_0_52;
	wire	[31:0]	VECTOR_1_DO_0_53;
	wire	[31:0]	VECTOR_1_DO_0_54;
	wire	[31:0]	VECTOR_1_DO_0_55;
	wire	[31:0]	VECTOR_1_DO_0_56;
	wire	[31:0]	VECTOR_1_DO_0_57;
	wire	[31:0]	VECTOR_1_DO_0_58;
	wire	[31:0]	VECTOR_1_DO_0_59;
	wire	[31:0]	VECTOR_1_DO_0_60;
	wire	[31:0]	VECTOR_1_DO_0_61;
	wire	[31:0]	VECTOR_1_DO_0_62;
	wire	[31:0]	VECTOR_1_DO_0_63;

	wire	[31:0]	VECTOR_1_DO_SUM;

	wire		VECTOR_1_EN_DI_0_0;
	wire		VECTOR_1_EN_DI_0_1;
	wire		VECTOR_1_EN_DI_1_0;
	wire		VECTOR_1_EN_DI_1_1;
	wire		VECTOR_1_EN_DO_0_0;
	wire		VECTOR_1_EN_DO_0_1;

	wire		VECTOR_1_SEL_DI_0_R;
	wire		VECTOR_1_SEL_DI_1_R;
	wire		VECTOR_1_SEL_DO_0_R;
	wire		VECTOR_1_SEL_DO_0_W;
	wire		VECTOR_1_SEL_DO_SUM_PREC;

	wire	[1:0]	VECTOR_1_SEL_OP;
	wire		VECTOR_1_SEL_PREC;
	wire	[2:0]	VECTOR_1_SEL_BLOCK_LOAD;

	wire		VECTOR_1_VECTOR_EN;
	wire		VECTOR_1_VECTOR_LOAD_EN;
	wire	[1:0]	VECTOR_1_VECTOR_MODE;
	
	
	VECTOR vector_1 (
		.DI_0_00(VECTOR_1_DI_0_00),	
		.DI_0_01(VECTOR_1_DI_0_01),	
		.DI_0_02(VECTOR_1_DI_0_02),	
		.DI_0_03(VECTOR_1_DI_0_03),	
		.DI_0_04(VECTOR_1_DI_0_04),	
		.DI_0_05(VECTOR_1_DI_0_05),	
		.DI_0_06(VECTOR_1_DI_0_06),	
		.DI_0_07(VECTOR_1_DI_0_07),	
		.DI_0_08(VECTOR_1_DI_0_08),	
		.DI_0_09(VECTOR_1_DI_0_09),	
		.DI_0_10(VECTOR_1_DI_0_10),	
		.DI_0_11(VECTOR_1_DI_0_11),	
		.DI_0_12(VECTOR_1_DI_0_12),	
		.DI_0_13(VECTOR_1_DI_0_13),	
		.DI_0_14(VECTOR_1_DI_0_14),	
		.DI_0_15(VECTOR_1_DI_0_15),	
		.DI_0_16(VECTOR_1_DI_0_16),	
		.DI_0_17(VECTOR_1_DI_0_17),	
		.DI_0_18(VECTOR_1_DI_0_18),	
		.DI_0_19(VECTOR_1_DI_0_19),	
		.DI_0_20(VECTOR_1_DI_0_20),	
		.DI_0_21(VECTOR_1_DI_0_21),	
		.DI_0_22(VECTOR_1_DI_0_22),	
		.DI_0_23(VECTOR_1_DI_0_23),	
		.DI_0_24(VECTOR_1_DI_0_24),	
		.DI_0_25(VECTOR_1_DI_0_25),	
		.DI_0_26(VECTOR_1_DI_0_26),	
		.DI_0_27(VECTOR_1_DI_0_27),	
		.DI_0_28(VECTOR_1_DI_0_28),	
		.DI_0_29(VECTOR_1_DI_0_29),	
		.DI_0_30(VECTOR_1_DI_0_30),	
		.DI_0_31(VECTOR_1_DI_0_31),	
		.DI_0_32(VECTOR_1_DI_0_32),	
		.DI_0_33(VECTOR_1_DI_0_33),	
		.DI_0_34(VECTOR_1_DI_0_34),	
		.DI_0_35(VECTOR_1_DI_0_35),	
		.DI_0_36(VECTOR_1_DI_0_36),	
		.DI_0_37(VECTOR_1_DI_0_37),	
		.DI_0_38(VECTOR_1_DI_0_38),	
		.DI_0_39(VECTOR_1_DI_0_39),	
		.DI_0_40(VECTOR_1_DI_0_40),	
		.DI_0_41(VECTOR_1_DI_0_41),	
		.DI_0_42(VECTOR_1_DI_0_42),	
		.DI_0_43(VECTOR_1_DI_0_43),	
		.DI_0_44(VECTOR_1_DI_0_44),	
		.DI_0_45(VECTOR_1_DI_0_45),	
		.DI_0_46(VECTOR_1_DI_0_46),	
		.DI_0_47(VECTOR_1_DI_0_47),	
		.DI_0_48(VECTOR_1_DI_0_48),	
		.DI_0_49(VECTOR_1_DI_0_49),	
		.DI_0_50(VECTOR_1_DI_0_50),	
		.DI_0_51(VECTOR_1_DI_0_51),	
		.DI_0_52(VECTOR_1_DI_0_52),	
		.DI_0_53(VECTOR_1_DI_0_53),	
		.DI_0_54(VECTOR_1_DI_0_54),	
		.DI_0_55(VECTOR_1_DI_0_55),	
		.DI_0_56(VECTOR_1_DI_0_56),	
		.DI_0_57(VECTOR_1_DI_0_57),	
		.DI_0_58(VECTOR_1_DI_0_58),	
		.DI_0_59(VECTOR_1_DI_0_59),	
		.DI_0_60(VECTOR_1_DI_0_60),	
		.DI_0_61(VECTOR_1_DI_0_61),	
		.DI_0_62(VECTOR_1_DI_0_62),	
		.DI_0_63(VECTOR_1_DI_0_63),	
		
		.DO_0_00(VECTOR_1_DO_0_00),	
		.DO_0_01(VECTOR_1_DO_0_01),	
		.DO_0_02(VECTOR_1_DO_0_02),	
		.DO_0_03(VECTOR_1_DO_0_03),	
		.DO_0_04(VECTOR_1_DO_0_04),	
		.DO_0_05(VECTOR_1_DO_0_05),	
		.DO_0_06(VECTOR_1_DO_0_06),	
		.DO_0_07(VECTOR_1_DO_0_07),	
		.DO_0_08(VECTOR_1_DO_0_08),	
		.DO_0_09(VECTOR_1_DO_0_09),	
		.DO_0_10(VECTOR_1_DO_0_10),	
		.DO_0_11(VECTOR_1_DO_0_11),	
		.DO_0_12(VECTOR_1_DO_0_12),	
		.DO_0_13(VECTOR_1_DO_0_13),	
		.DO_0_14(VECTOR_1_DO_0_14),	
		.DO_0_15(VECTOR_1_DO_0_15),	
		.DO_0_16(VECTOR_1_DO_0_16),	
		.DO_0_17(VECTOR_1_DO_0_17),	
		.DO_0_18(VECTOR_1_DO_0_18),	
		.DO_0_19(VECTOR_1_DO_0_19),	
		.DO_0_20(VECTOR_1_DO_0_20),	
		.DO_0_21(VECTOR_1_DO_0_21),	
		.DO_0_22(VECTOR_1_DO_0_22),	
		.DO_0_23(VECTOR_1_DO_0_23),	
		.DO_0_24(VECTOR_1_DO_0_24),	
		.DO_0_25(VECTOR_1_DO_0_25),	
		.DO_0_26(VECTOR_1_DO_0_26),	
		.DO_0_27(VECTOR_1_DO_0_27),	
		.DO_0_28(VECTOR_1_DO_0_28),	
		.DO_0_29(VECTOR_1_DO_0_29),	
		.DO_0_30(VECTOR_1_DO_0_30),	
		.DO_0_31(VECTOR_1_DO_0_31),	
		.DO_0_32(VECTOR_1_DO_0_32),	
		.DO_0_33(VECTOR_1_DO_0_33),	
		.DO_0_34(VECTOR_1_DO_0_34),	
		.DO_0_35(VECTOR_1_DO_0_35),	
		.DO_0_36(VECTOR_1_DO_0_36),	
		.DO_0_37(VECTOR_1_DO_0_37),	
		.DO_0_38(VECTOR_1_DO_0_38),	
		.DO_0_39(VECTOR_1_DO_0_39),	
		.DO_0_40(VECTOR_1_DO_0_40),	
		.DO_0_41(VECTOR_1_DO_0_41),	
		.DO_0_42(VECTOR_1_DO_0_42),	
		.DO_0_43(VECTOR_1_DO_0_43),	
		.DO_0_44(VECTOR_1_DO_0_44),	
		.DO_0_45(VECTOR_1_DO_0_45),	
		.DO_0_46(VECTOR_1_DO_0_46),	
		.DO_0_47(VECTOR_1_DO_0_47),	
		.DO_0_48(VECTOR_1_DO_0_48),	
		.DO_0_49(VECTOR_1_DO_0_49),	
		.DO_0_50(VECTOR_1_DO_0_50),	
		.DO_0_51(VECTOR_1_DO_0_51),	
		.DO_0_52(VECTOR_1_DO_0_52),	
		.DO_0_53(VECTOR_1_DO_0_53),	
		.DO_0_54(VECTOR_1_DO_0_54),	
		.DO_0_55(VECTOR_1_DO_0_55),	
		.DO_0_56(VECTOR_1_DO_0_56),	
		.DO_0_57(VECTOR_1_DO_0_57),	
		.DO_0_58(VECTOR_1_DO_0_58),	
		.DO_0_59(VECTOR_1_DO_0_59),	
		.DO_0_60(VECTOR_1_DO_0_60),	
		.DO_0_61(VECTOR_1_DO_0_61),	
		.DO_0_62(VECTOR_1_DO_0_62),	
		.DO_0_63(VECTOR_1_DO_0_63),

		.DO_SUM(VECTOR_1_DO_SUM),

		.EN_DI_0_0(VECTOR_1_EN_DI_0_0),
		.EN_DI_0_1(VECTOR_1_EN_DI_0_1),
		.EN_DI_1_0(VECTOR_1_EN_DI_1_0),
		.EN_DI_1_1(VECTOR_1_EN_DI_1_1),
		.EN_DO_0_0(VECTOR_1_EN_DO_0_0),
		.EN_DO_0_1(VECTOR_1_EN_DO_0_1),

		.SEL_DI_0_R(VECTOR_1_SEL_DI_0_R),
		.SEL_DI_1_R(VECTOR_1_SEL_DI_1_R),
		.SEL_DO_0_R(VECTOR_1_SEL_DO_0_R),
		.SEL_DO_0_W(VECTOR_1_SEL_DO_0_W),
		.SEL_DO_SUM_PREC(VECTOR_1_SEL_DO_SUM_PREC),

		.SEL_OP(VECTOR_1_SEL_OP),
		.SEL_PREC(VECTOR_1_SEL_PREC),
		.SEL_BLOCK_LOAD(VECTOR_1_SEL_BLOCK_LOAD),

		.VECTOR_EN(VECTOR_1_VECTOR_EN),
		.VECTOR_LOAD_EN(VECTOR_1_VECTOR_LOAD_EN),
		.VECTOR_MODE(VECTOR_1_VECTOR_MODE),

		.CLK(CLK),
		.RSTn(RSTn)
	);


	wire	[31:0]	VECTOR_2_DI_0_00;
	wire	[31:0]	VECTOR_2_DI_0_01;
	wire	[31:0]	VECTOR_2_DI_0_02;
	wire	[31:0]	VECTOR_2_DI_0_03;
	wire	[31:0]	VECTOR_2_DI_0_04;
	wire	[31:0]	VECTOR_2_DI_0_05;
	wire	[31:0]	VECTOR_2_DI_0_06;
	wire	[31:0]	VECTOR_2_DI_0_07;
	wire	[31:0]	VECTOR_2_DI_0_08;
	wire	[31:0]	VECTOR_2_DI_0_09;
	wire	[31:0]	VECTOR_2_DI_0_10;
	wire	[31:0]	VECTOR_2_DI_0_11;
	wire	[31:0]	VECTOR_2_DI_0_12;
	wire	[31:0]	VECTOR_2_DI_0_13;
	wire	[31:0]	VECTOR_2_DI_0_14;
	wire	[31:0]	VECTOR_2_DI_0_15;
	wire	[31:0]	VECTOR_2_DI_0_16;
	wire	[31:0]	VECTOR_2_DI_0_17;
	wire	[31:0]	VECTOR_2_DI_0_18;
	wire	[31:0]	VECTOR_2_DI_0_19;
	wire	[31:0]	VECTOR_2_DI_0_20;
	wire	[31:0]	VECTOR_2_DI_0_21;
	wire	[31:0]	VECTOR_2_DI_0_22;
	wire	[31:0]	VECTOR_2_DI_0_23;
	wire	[31:0]	VECTOR_2_DI_0_24;
	wire	[31:0]	VECTOR_2_DI_0_25;
	wire	[31:0]	VECTOR_2_DI_0_26;
	wire	[31:0]	VECTOR_2_DI_0_27;
	wire	[31:0]	VECTOR_2_DI_0_28;
	wire	[31:0]	VECTOR_2_DI_0_29;
	wire	[31:0]	VECTOR_2_DI_0_30;
	wire	[31:0]	VECTOR_2_DI_0_31;
	wire	[31:0]	VECTOR_2_DI_0_32;
	wire	[31:0]	VECTOR_2_DI_0_33;
	wire	[31:0]	VECTOR_2_DI_0_34;
	wire	[31:0]	VECTOR_2_DI_0_35;
	wire	[31:0]	VECTOR_2_DI_0_36;
	wire	[31:0]	VECTOR_2_DI_0_37;
	wire	[31:0]	VECTOR_2_DI_0_38;
	wire	[31:0]	VECTOR_2_DI_0_39;
	wire	[31:0]	VECTOR_2_DI_0_40;
	wire	[31:0]	VECTOR_2_DI_0_41;
	wire	[31:0]	VECTOR_2_DI_0_42;
	wire	[31:0]	VECTOR_2_DI_0_43;
	wire	[31:0]	VECTOR_2_DI_0_44;
	wire	[31:0]	VECTOR_2_DI_0_45;
	wire	[31:0]	VECTOR_2_DI_0_46;
	wire	[31:0]	VECTOR_2_DI_0_47;
	wire	[31:0]	VECTOR_2_DI_0_48;
	wire	[31:0]	VECTOR_2_DI_0_49;
	wire	[31:0]	VECTOR_2_DI_0_50;
	wire	[31:0]	VECTOR_2_DI_0_51;
	wire	[31:0]	VECTOR_2_DI_0_52;
	wire	[31:0]	VECTOR_2_DI_0_53;
	wire	[31:0]	VECTOR_2_DI_0_54;
	wire	[31:0]	VECTOR_2_DI_0_55;
	wire	[31:0]	VECTOR_2_DI_0_56;
	wire	[31:0]	VECTOR_2_DI_0_57;
	wire	[31:0]	VECTOR_2_DI_0_58;
	wire	[31:0]	VECTOR_2_DI_0_59;
	wire	[31:0]	VECTOR_2_DI_0_60;
	wire	[31:0]	VECTOR_2_DI_0_61;
	wire	[31:0]	VECTOR_2_DI_0_62;
	wire	[31:0]	VECTOR_2_DI_0_63;
	
	wire	[31:0]	VECTOR_2_DO_0_00;
	wire	[31:0]	VECTOR_2_DO_0_01;
	wire	[31:0]	VECTOR_2_DO_0_02;
	wire	[31:0]	VECTOR_2_DO_0_03;
	wire	[31:0]	VECTOR_2_DO_0_04;
	wire	[31:0]	VECTOR_2_DO_0_05;
	wire	[31:0]	VECTOR_2_DO_0_06;
	wire	[31:0]	VECTOR_2_DO_0_07;
	wire	[31:0]	VECTOR_2_DO_0_08;
	wire	[31:0]	VECTOR_2_DO_0_09;
	wire	[31:0]	VECTOR_2_DO_0_10;
	wire	[31:0]	VECTOR_2_DO_0_11;
	wire	[31:0]	VECTOR_2_DO_0_12;
	wire	[31:0]	VECTOR_2_DO_0_13;
	wire	[31:0]	VECTOR_2_DO_0_14;
	wire	[31:0]	VECTOR_2_DO_0_15;
	wire	[31:0]	VECTOR_2_DO_0_16;
	wire	[31:0]	VECTOR_2_DO_0_17;
	wire	[31:0]	VECTOR_2_DO_0_18;
	wire	[31:0]	VECTOR_2_DO_0_19;
	wire	[31:0]	VECTOR_2_DO_0_20;
	wire	[31:0]	VECTOR_2_DO_0_21;
	wire	[31:0]	VECTOR_2_DO_0_22;
	wire	[31:0]	VECTOR_2_DO_0_23;
	wire	[31:0]	VECTOR_2_DO_0_24;
	wire	[31:0]	VECTOR_2_DO_0_25;
	wire	[31:0]	VECTOR_2_DO_0_26;
	wire	[31:0]	VECTOR_2_DO_0_27;
	wire	[31:0]	VECTOR_2_DO_0_28;
	wire	[31:0]	VECTOR_2_DO_0_29;
	wire	[31:0]	VECTOR_2_DO_0_30;
	wire	[31:0]	VECTOR_2_DO_0_31;
	wire	[31:0]	VECTOR_2_DO_0_32;
	wire	[31:0]	VECTOR_2_DO_0_33;
	wire	[31:0]	VECTOR_2_DO_0_34;
	wire	[31:0]	VECTOR_2_DO_0_35;
	wire	[31:0]	VECTOR_2_DO_0_36;
	wire	[31:0]	VECTOR_2_DO_0_37;
	wire	[31:0]	VECTOR_2_DO_0_38;
	wire	[31:0]	VECTOR_2_DO_0_39;
	wire	[31:0]	VECTOR_2_DO_0_40;
	wire	[31:0]	VECTOR_2_DO_0_41;
	wire	[31:0]	VECTOR_2_DO_0_42;
	wire	[31:0]	VECTOR_2_DO_0_43;
	wire	[31:0]	VECTOR_2_DO_0_44;
	wire	[31:0]	VECTOR_2_DO_0_45;
	wire	[31:0]	VECTOR_2_DO_0_46;
	wire	[31:0]	VECTOR_2_DO_0_47;
	wire	[31:0]	VECTOR_2_DO_0_48;
	wire	[31:0]	VECTOR_2_DO_0_49;
	wire	[31:0]	VECTOR_2_DO_0_50;
	wire	[31:0]	VECTOR_2_DO_0_51;
	wire	[31:0]	VECTOR_2_DO_0_52;
	wire	[31:0]	VECTOR_2_DO_0_53;
	wire	[31:0]	VECTOR_2_DO_0_54;
	wire	[31:0]	VECTOR_2_DO_0_55;
	wire	[31:0]	VECTOR_2_DO_0_56;
	wire	[31:0]	VECTOR_2_DO_0_57;
	wire	[31:0]	VECTOR_2_DO_0_58;
	wire	[31:0]	VECTOR_2_DO_0_59;
	wire	[31:0]	VECTOR_2_DO_0_60;
	wire	[31:0]	VECTOR_2_DO_0_61;
	wire	[31:0]	VECTOR_2_DO_0_62;
	wire	[31:0]	VECTOR_2_DO_0_63;

	wire	[31:0]	VECTOR_2_DO_SUM;

	wire		VECTOR_2_EN_DI_0_0;
	wire		VECTOR_2_EN_DI_0_1;
	wire		VECTOR_2_EN_DI_1_0;
	wire		VECTOR_2_EN_DI_1_1;
	wire		VECTOR_2_EN_DO_0_0;
	wire		VECTOR_2_EN_DO_0_1;

	wire		VECTOR_2_SEL_DI_0_R;
	wire		VECTOR_2_SEL_DI_1_R;
	wire		VECTOR_2_SEL_DO_0_R;
	wire		VECTOR_2_SEL_DO_0_W;
	wire		VECTOR_2_SEL_DO_SUM_PREC;

	wire	[1:0]	VECTOR_2_SEL_OP;
	wire		VECTOR_2_SEL_PREC;
	wire	[2:0]	VECTOR_2_SEL_BLOCK_LOAD;

	wire		VECTOR_2_VECTOR_EN;
	wire		VECTOR_2_VECTOR_LOAD_EN;
	wire	[1:0]	VECTOR_2_VECTOR_MODE;
	
	
	VECTOR vector_2 (
		.DI_0_00(VECTOR_2_DI_0_00),	
		.DI_0_01(VECTOR_2_DI_0_01),	
		.DI_0_02(VECTOR_2_DI_0_02),	
		.DI_0_03(VECTOR_2_DI_0_03),	
		.DI_0_04(VECTOR_2_DI_0_04),	
		.DI_0_05(VECTOR_2_DI_0_05),	
		.DI_0_06(VECTOR_2_DI_0_06),	
		.DI_0_07(VECTOR_2_DI_0_07),	
		.DI_0_08(VECTOR_2_DI_0_08),	
		.DI_0_09(VECTOR_2_DI_0_09),	
		.DI_0_10(VECTOR_2_DI_0_10),	
		.DI_0_11(VECTOR_2_DI_0_11),	
		.DI_0_12(VECTOR_2_DI_0_12),	
		.DI_0_13(VECTOR_2_DI_0_13),	
		.DI_0_14(VECTOR_2_DI_0_14),	
		.DI_0_15(VECTOR_2_DI_0_15),	
		.DI_0_16(VECTOR_2_DI_0_16),	
		.DI_0_17(VECTOR_2_DI_0_17),	
		.DI_0_18(VECTOR_2_DI_0_18),	
		.DI_0_19(VECTOR_2_DI_0_19),	
		.DI_0_20(VECTOR_2_DI_0_20),	
		.DI_0_21(VECTOR_2_DI_0_21),	
		.DI_0_22(VECTOR_2_DI_0_22),	
		.DI_0_23(VECTOR_2_DI_0_23),	
		.DI_0_24(VECTOR_2_DI_0_24),	
		.DI_0_25(VECTOR_2_DI_0_25),	
		.DI_0_26(VECTOR_2_DI_0_26),	
		.DI_0_27(VECTOR_2_DI_0_27),	
		.DI_0_28(VECTOR_2_DI_0_28),	
		.DI_0_29(VECTOR_2_DI_0_29),	
		.DI_0_30(VECTOR_2_DI_0_30),	
		.DI_0_31(VECTOR_2_DI_0_31),	
		.DI_0_32(VECTOR_2_DI_0_32),	
		.DI_0_33(VECTOR_2_DI_0_33),	
		.DI_0_34(VECTOR_2_DI_0_34),	
		.DI_0_35(VECTOR_2_DI_0_35),	
		.DI_0_36(VECTOR_2_DI_0_36),	
		.DI_0_37(VECTOR_2_DI_0_37),	
		.DI_0_38(VECTOR_2_DI_0_38),	
		.DI_0_39(VECTOR_2_DI_0_39),	
		.DI_0_40(VECTOR_2_DI_0_40),	
		.DI_0_41(VECTOR_2_DI_0_41),	
		.DI_0_42(VECTOR_2_DI_0_42),	
		.DI_0_43(VECTOR_2_DI_0_43),	
		.DI_0_44(VECTOR_2_DI_0_44),	
		.DI_0_45(VECTOR_2_DI_0_45),	
		.DI_0_46(VECTOR_2_DI_0_46),	
		.DI_0_47(VECTOR_2_DI_0_47),	
		.DI_0_48(VECTOR_2_DI_0_48),	
		.DI_0_49(VECTOR_2_DI_0_49),	
		.DI_0_50(VECTOR_2_DI_0_50),	
		.DI_0_51(VECTOR_2_DI_0_51),	
		.DI_0_52(VECTOR_2_DI_0_52),	
		.DI_0_53(VECTOR_2_DI_0_53),	
		.DI_0_54(VECTOR_2_DI_0_54),	
		.DI_0_55(VECTOR_2_DI_0_55),	
		.DI_0_56(VECTOR_2_DI_0_56),	
		.DI_0_57(VECTOR_2_DI_0_57),	
		.DI_0_58(VECTOR_2_DI_0_58),	
		.DI_0_59(VECTOR_2_DI_0_59),	
		.DI_0_60(VECTOR_2_DI_0_60),	
		.DI_0_61(VECTOR_2_DI_0_61),	
		.DI_0_62(VECTOR_2_DI_0_62),	
		.DI_0_63(VECTOR_2_DI_0_63),	
		
		.DO_0_00(VECTOR_2_DO_0_00),	
		.DO_0_01(VECTOR_2_DO_0_01),	
		.DO_0_02(VECTOR_2_DO_0_02),	
		.DO_0_03(VECTOR_2_DO_0_03),	
		.DO_0_04(VECTOR_2_DO_0_04),	
		.DO_0_05(VECTOR_2_DO_0_05),	
		.DO_0_06(VECTOR_2_DO_0_06),	
		.DO_0_07(VECTOR_2_DO_0_07),	
		.DO_0_08(VECTOR_2_DO_0_08),	
		.DO_0_09(VECTOR_2_DO_0_09),	
		.DO_0_10(VECTOR_2_DO_0_10),	
		.DO_0_11(VECTOR_2_DO_0_11),	
		.DO_0_12(VECTOR_2_DO_0_12),	
		.DO_0_13(VECTOR_2_DO_0_13),	
		.DO_0_14(VECTOR_2_DO_0_14),	
		.DO_0_15(VECTOR_2_DO_0_15),	
		.DO_0_16(VECTOR_2_DO_0_16),	
		.DO_0_17(VECTOR_2_DO_0_17),	
		.DO_0_18(VECTOR_2_DO_0_18),	
		.DO_0_19(VECTOR_2_DO_0_19),	
		.DO_0_20(VECTOR_2_DO_0_20),	
		.DO_0_21(VECTOR_2_DO_0_21),	
		.DO_0_22(VECTOR_2_DO_0_22),	
		.DO_0_23(VECTOR_2_DO_0_23),	
		.DO_0_24(VECTOR_2_DO_0_24),	
		.DO_0_25(VECTOR_2_DO_0_25),	
		.DO_0_26(VECTOR_2_DO_0_26),	
		.DO_0_27(VECTOR_2_DO_0_27),	
		.DO_0_28(VECTOR_2_DO_0_28),	
		.DO_0_29(VECTOR_2_DO_0_29),	
		.DO_0_30(VECTOR_2_DO_0_30),	
		.DO_0_31(VECTOR_2_DO_0_31),	
		.DO_0_32(VECTOR_2_DO_0_32),	
		.DO_0_33(VECTOR_2_DO_0_33),	
		.DO_0_34(VECTOR_2_DO_0_34),	
		.DO_0_35(VECTOR_2_DO_0_35),	
		.DO_0_36(VECTOR_2_DO_0_36),	
		.DO_0_37(VECTOR_2_DO_0_37),	
		.DO_0_38(VECTOR_2_DO_0_38),	
		.DO_0_39(VECTOR_2_DO_0_39),	
		.DO_0_40(VECTOR_2_DO_0_40),	
		.DO_0_41(VECTOR_2_DO_0_41),	
		.DO_0_42(VECTOR_2_DO_0_42),	
		.DO_0_43(VECTOR_2_DO_0_43),	
		.DO_0_44(VECTOR_2_DO_0_44),	
		.DO_0_45(VECTOR_2_DO_0_45),	
		.DO_0_46(VECTOR_2_DO_0_46),	
		.DO_0_47(VECTOR_2_DO_0_47),	
		.DO_0_48(VECTOR_2_DO_0_48),	
		.DO_0_49(VECTOR_2_DO_0_49),	
		.DO_0_50(VECTOR_2_DO_0_50),	
		.DO_0_51(VECTOR_2_DO_0_51),	
		.DO_0_52(VECTOR_2_DO_0_52),	
		.DO_0_53(VECTOR_2_DO_0_53),	
		.DO_0_54(VECTOR_2_DO_0_54),	
		.DO_0_55(VECTOR_2_DO_0_55),	
		.DO_0_56(VECTOR_2_DO_0_56),	
		.DO_0_57(VECTOR_2_DO_0_57),	
		.DO_0_58(VECTOR_2_DO_0_58),	
		.DO_0_59(VECTOR_2_DO_0_59),	
		.DO_0_60(VECTOR_2_DO_0_60),	
		.DO_0_61(VECTOR_2_DO_0_61),	
		.DO_0_62(VECTOR_2_DO_0_62),	
		.DO_0_63(VECTOR_2_DO_0_63),

		.DO_SUM(VECTOR_2_DO_SUM),

		.EN_DI_0_0(VECTOR_2_EN_DI_0_0),
		.EN_DI_0_1(VECTOR_2_EN_DI_0_1),
		.EN_DI_1_0(VECTOR_2_EN_DI_1_0),
		.EN_DI_1_1(VECTOR_2_EN_DI_1_1),
		.EN_DO_0_0(VECTOR_2_EN_DO_0_0),
		.EN_DO_0_1(VECTOR_2_EN_DO_0_1),

		.SEL_DI_0_R(VECTOR_2_SEL_DI_0_R),
		.SEL_DI_1_R(VECTOR_2_SEL_DI_1_R),
		.SEL_DO_0_R(VECTOR_2_SEL_DO_0_R),
		.SEL_DO_0_W(VECTOR_2_SEL_DO_0_W),
		.SEL_DO_SUM_PREC(VECTOR_2_SEL_DO_SUM_PREC),

		.SEL_OP(VECTOR_2_SEL_OP),
		.SEL_PREC(VECTOR_2_SEL_PREC),
		.SEL_BLOCK_LOAD(VECTOR_2_SEL_BLOCK_LOAD),

		.VECTOR_EN(VECTOR_2_VECTOR_EN),
		.VECTOR_LOAD_EN(VECTOR_2_VECTOR_LOAD_EN),
		.VECTOR_MODE(VECTOR_2_VECTOR_MODE),

		.CLK(CLK),
		.RSTn(RSTn)
	);


	wire	[31:0]	VECTOR_3_DI_0_00;
	wire	[31:0]	VECTOR_3_DI_0_01;
	wire	[31:0]	VECTOR_3_DI_0_02;
	wire	[31:0]	VECTOR_3_DI_0_03;
	wire	[31:0]	VECTOR_3_DI_0_04;
	wire	[31:0]	VECTOR_3_DI_0_05;
	wire	[31:0]	VECTOR_3_DI_0_06;
	wire	[31:0]	VECTOR_3_DI_0_07;
	wire	[31:0]	VECTOR_3_DI_0_08;
	wire	[31:0]	VECTOR_3_DI_0_09;
	wire	[31:0]	VECTOR_3_DI_0_10;
	wire	[31:0]	VECTOR_3_DI_0_11;
	wire	[31:0]	VECTOR_3_DI_0_12;
	wire	[31:0]	VECTOR_3_DI_0_13;
	wire	[31:0]	VECTOR_3_DI_0_14;
	wire	[31:0]	VECTOR_3_DI_0_15;
	wire	[31:0]	VECTOR_3_DI_0_16;
	wire	[31:0]	VECTOR_3_DI_0_17;
	wire	[31:0]	VECTOR_3_DI_0_18;
	wire	[31:0]	VECTOR_3_DI_0_19;
	wire	[31:0]	VECTOR_3_DI_0_20;
	wire	[31:0]	VECTOR_3_DI_0_21;
	wire	[31:0]	VECTOR_3_DI_0_22;
	wire	[31:0]	VECTOR_3_DI_0_23;
	wire	[31:0]	VECTOR_3_DI_0_24;
	wire	[31:0]	VECTOR_3_DI_0_25;
	wire	[31:0]	VECTOR_3_DI_0_26;
	wire	[31:0]	VECTOR_3_DI_0_27;
	wire	[31:0]	VECTOR_3_DI_0_28;
	wire	[31:0]	VECTOR_3_DI_0_29;
	wire	[31:0]	VECTOR_3_DI_0_30;
	wire	[31:0]	VECTOR_3_DI_0_31;
	wire	[31:0]	VECTOR_3_DI_0_32;
	wire	[31:0]	VECTOR_3_DI_0_33;
	wire	[31:0]	VECTOR_3_DI_0_34;
	wire	[31:0]	VECTOR_3_DI_0_35;
	wire	[31:0]	VECTOR_3_DI_0_36;
	wire	[31:0]	VECTOR_3_DI_0_37;
	wire	[31:0]	VECTOR_3_DI_0_38;
	wire	[31:0]	VECTOR_3_DI_0_39;
	wire	[31:0]	VECTOR_3_DI_0_40;
	wire	[31:0]	VECTOR_3_DI_0_41;
	wire	[31:0]	VECTOR_3_DI_0_42;
	wire	[31:0]	VECTOR_3_DI_0_43;
	wire	[31:0]	VECTOR_3_DI_0_44;
	wire	[31:0]	VECTOR_3_DI_0_45;
	wire	[31:0]	VECTOR_3_DI_0_46;
	wire	[31:0]	VECTOR_3_DI_0_47;
	wire	[31:0]	VECTOR_3_DI_0_48;
	wire	[31:0]	VECTOR_3_DI_0_49;
	wire	[31:0]	VECTOR_3_DI_0_50;
	wire	[31:0]	VECTOR_3_DI_0_51;
	wire	[31:0]	VECTOR_3_DI_0_52;
	wire	[31:0]	VECTOR_3_DI_0_53;
	wire	[31:0]	VECTOR_3_DI_0_54;
	wire	[31:0]	VECTOR_3_DI_0_55;
	wire	[31:0]	VECTOR_3_DI_0_56;
	wire	[31:0]	VECTOR_3_DI_0_57;
	wire	[31:0]	VECTOR_3_DI_0_58;
	wire	[31:0]	VECTOR_3_DI_0_59;
	wire	[31:0]	VECTOR_3_DI_0_60;
	wire	[31:0]	VECTOR_3_DI_0_61;
	wire	[31:0]	VECTOR_3_DI_0_62;
	wire	[31:0]	VECTOR_3_DI_0_63;
	
	wire	[31:0]	VECTOR_3_DO_0_00;
	wire	[31:0]	VECTOR_3_DO_0_01;
	wire	[31:0]	VECTOR_3_DO_0_02;
	wire	[31:0]	VECTOR_3_DO_0_03;
	wire	[31:0]	VECTOR_3_DO_0_04;
	wire	[31:0]	VECTOR_3_DO_0_05;
	wire	[31:0]	VECTOR_3_DO_0_06;
	wire	[31:0]	VECTOR_3_DO_0_07;
	wire	[31:0]	VECTOR_3_DO_0_08;
	wire	[31:0]	VECTOR_3_DO_0_09;
	wire	[31:0]	VECTOR_3_DO_0_10;
	wire	[31:0]	VECTOR_3_DO_0_11;
	wire	[31:0]	VECTOR_3_DO_0_12;
	wire	[31:0]	VECTOR_3_DO_0_13;
	wire	[31:0]	VECTOR_3_DO_0_14;
	wire	[31:0]	VECTOR_3_DO_0_15;
	wire	[31:0]	VECTOR_3_DO_0_16;
	wire	[31:0]	VECTOR_3_DO_0_17;
	wire	[31:0]	VECTOR_3_DO_0_18;
	wire	[31:0]	VECTOR_3_DO_0_19;
	wire	[31:0]	VECTOR_3_DO_0_20;
	wire	[31:0]	VECTOR_3_DO_0_21;
	wire	[31:0]	VECTOR_3_DO_0_22;
	wire	[31:0]	VECTOR_3_DO_0_23;
	wire	[31:0]	VECTOR_3_DO_0_24;
	wire	[31:0]	VECTOR_3_DO_0_25;
	wire	[31:0]	VECTOR_3_DO_0_26;
	wire	[31:0]	VECTOR_3_DO_0_27;
	wire	[31:0]	VECTOR_3_DO_0_28;
	wire	[31:0]	VECTOR_3_DO_0_29;
	wire	[31:0]	VECTOR_3_DO_0_30;
	wire	[31:0]	VECTOR_3_DO_0_31;
	wire	[31:0]	VECTOR_3_DO_0_32;
	wire	[31:0]	VECTOR_3_DO_0_33;
	wire	[31:0]	VECTOR_3_DO_0_34;
	wire	[31:0]	VECTOR_3_DO_0_35;
	wire	[31:0]	VECTOR_3_DO_0_36;
	wire	[31:0]	VECTOR_3_DO_0_37;
	wire	[31:0]	VECTOR_3_DO_0_38;
	wire	[31:0]	VECTOR_3_DO_0_39;
	wire	[31:0]	VECTOR_3_DO_0_40;
	wire	[31:0]	VECTOR_3_DO_0_41;
	wire	[31:0]	VECTOR_3_DO_0_42;
	wire	[31:0]	VECTOR_3_DO_0_43;
	wire	[31:0]	VECTOR_3_DO_0_44;
	wire	[31:0]	VECTOR_3_DO_0_45;
	wire	[31:0]	VECTOR_3_DO_0_46;
	wire	[31:0]	VECTOR_3_DO_0_47;
	wire	[31:0]	VECTOR_3_DO_0_48;
	wire	[31:0]	VECTOR_3_DO_0_49;
	wire	[31:0]	VECTOR_3_DO_0_50;
	wire	[31:0]	VECTOR_3_DO_0_51;
	wire	[31:0]	VECTOR_3_DO_0_52;
	wire	[31:0]	VECTOR_3_DO_0_53;
	wire	[31:0]	VECTOR_3_DO_0_54;
	wire	[31:0]	VECTOR_3_DO_0_55;
	wire	[31:0]	VECTOR_3_DO_0_56;
	wire	[31:0]	VECTOR_3_DO_0_57;
	wire	[31:0]	VECTOR_3_DO_0_58;
	wire	[31:0]	VECTOR_3_DO_0_59;
	wire	[31:0]	VECTOR_3_DO_0_60;
	wire	[31:0]	VECTOR_3_DO_0_61;
	wire	[31:0]	VECTOR_3_DO_0_62;
	wire	[31:0]	VECTOR_3_DO_0_63;

	wire	[31:0]	VECTOR_3_DO_SUM;

	wire		VECTOR_3_EN_DI_0_0;
	wire		VECTOR_3_EN_DI_0_1;
	wire		VECTOR_3_EN_DI_1_0;
	wire		VECTOR_3_EN_DI_1_1;
	wire		VECTOR_3_EN_DO_0_0;
	wire		VECTOR_3_EN_DO_0_1;

	wire		VECTOR_3_SEL_DI_0_R;
	wire		VECTOR_3_SEL_DI_1_R;
	wire		VECTOR_3_SEL_DO_0_R;
	wire		VECTOR_3_SEL_DO_0_W;
	wire		VECTOR_3_SEL_DO_SUM_PREC;

	wire	[1:0]	VECTOR_3_SEL_OP;
	wire		VECTOR_3_SEL_PREC;
	wire	[2:0]	VECTOR_3_SEL_BLOCK_LOAD;

	wire		VECTOR_3_VECTOR_EN;
	wire		VECTOR_3_VECTOR_LOAD_EN;
	wire	[1:0]	VECTOR_3_VECTOR_MODE;
	
	
	VECTOR vector_3 (
		.DI_0_00(VECTOR_3_DI_0_00),	
		.DI_0_01(VECTOR_3_DI_0_01),	
		.DI_0_02(VECTOR_3_DI_0_02),	
		.DI_0_03(VECTOR_3_DI_0_03),	
		.DI_0_04(VECTOR_3_DI_0_04),	
		.DI_0_05(VECTOR_3_DI_0_05),	
		.DI_0_06(VECTOR_3_DI_0_06),	
		.DI_0_07(VECTOR_3_DI_0_07),	
		.DI_0_08(VECTOR_3_DI_0_08),	
		.DI_0_09(VECTOR_3_DI_0_09),	
		.DI_0_10(VECTOR_3_DI_0_10),	
		.DI_0_11(VECTOR_3_DI_0_11),	
		.DI_0_12(VECTOR_3_DI_0_12),	
		.DI_0_13(VECTOR_3_DI_0_13),	
		.DI_0_14(VECTOR_3_DI_0_14),	
		.DI_0_15(VECTOR_3_DI_0_15),	
		.DI_0_16(VECTOR_3_DI_0_16),	
		.DI_0_17(VECTOR_3_DI_0_17),	
		.DI_0_18(VECTOR_3_DI_0_18),	
		.DI_0_19(VECTOR_3_DI_0_19),	
		.DI_0_20(VECTOR_3_DI_0_20),	
		.DI_0_21(VECTOR_3_DI_0_21),	
		.DI_0_22(VECTOR_3_DI_0_22),	
		.DI_0_23(VECTOR_3_DI_0_23),	
		.DI_0_24(VECTOR_3_DI_0_24),	
		.DI_0_25(VECTOR_3_DI_0_25),	
		.DI_0_26(VECTOR_3_DI_0_26),	
		.DI_0_27(VECTOR_3_DI_0_27),	
		.DI_0_28(VECTOR_3_DI_0_28),	
		.DI_0_29(VECTOR_3_DI_0_29),	
		.DI_0_30(VECTOR_3_DI_0_30),	
		.DI_0_31(VECTOR_3_DI_0_31),	
		.DI_0_32(VECTOR_3_DI_0_32),	
		.DI_0_33(VECTOR_3_DI_0_33),	
		.DI_0_34(VECTOR_3_DI_0_34),	
		.DI_0_35(VECTOR_3_DI_0_35),	
		.DI_0_36(VECTOR_3_DI_0_36),	
		.DI_0_37(VECTOR_3_DI_0_37),	
		.DI_0_38(VECTOR_3_DI_0_38),	
		.DI_0_39(VECTOR_3_DI_0_39),	
		.DI_0_40(VECTOR_3_DI_0_40),	
		.DI_0_41(VECTOR_3_DI_0_41),	
		.DI_0_42(VECTOR_3_DI_0_42),	
		.DI_0_43(VECTOR_3_DI_0_43),	
		.DI_0_44(VECTOR_3_DI_0_44),	
		.DI_0_45(VECTOR_3_DI_0_45),	
		.DI_0_46(VECTOR_3_DI_0_46),	
		.DI_0_47(VECTOR_3_DI_0_47),	
		.DI_0_48(VECTOR_3_DI_0_48),	
		.DI_0_49(VECTOR_3_DI_0_49),	
		.DI_0_50(VECTOR_3_DI_0_50),	
		.DI_0_51(VECTOR_3_DI_0_51),	
		.DI_0_52(VECTOR_3_DI_0_52),	
		.DI_0_53(VECTOR_3_DI_0_53),	
		.DI_0_54(VECTOR_3_DI_0_54),	
		.DI_0_55(VECTOR_3_DI_0_55),	
		.DI_0_56(VECTOR_3_DI_0_56),	
		.DI_0_57(VECTOR_3_DI_0_57),	
		.DI_0_58(VECTOR_3_DI_0_58),	
		.DI_0_59(VECTOR_3_DI_0_59),	
		.DI_0_60(VECTOR_3_DI_0_60),	
		.DI_0_61(VECTOR_3_DI_0_61),	
		.DI_0_62(VECTOR_3_DI_0_62),	
		.DI_0_63(VECTOR_3_DI_0_63),	
		
		.DO_0_00(VECTOR_3_DO_0_00),	
		.DO_0_01(VECTOR_3_DO_0_01),	
		.DO_0_02(VECTOR_3_DO_0_02),	
		.DO_0_03(VECTOR_3_DO_0_03),	
		.DO_0_04(VECTOR_3_DO_0_04),	
		.DO_0_05(VECTOR_3_DO_0_05),	
		.DO_0_06(VECTOR_3_DO_0_06),	
		.DO_0_07(VECTOR_3_DO_0_07),	
		.DO_0_08(VECTOR_3_DO_0_08),	
		.DO_0_09(VECTOR_3_DO_0_09),	
		.DO_0_10(VECTOR_3_DO_0_10),	
		.DO_0_11(VECTOR_3_DO_0_11),	
		.DO_0_12(VECTOR_3_DO_0_12),	
		.DO_0_13(VECTOR_3_DO_0_13),	
		.DO_0_14(VECTOR_3_DO_0_14),	
		.DO_0_15(VECTOR_3_DO_0_15),	
		.DO_0_16(VECTOR_3_DO_0_16),	
		.DO_0_17(VECTOR_3_DO_0_17),	
		.DO_0_18(VECTOR_3_DO_0_18),	
		.DO_0_19(VECTOR_3_DO_0_19),	
		.DO_0_20(VECTOR_3_DO_0_20),	
		.DO_0_21(VECTOR_3_DO_0_21),	
		.DO_0_22(VECTOR_3_DO_0_22),	
		.DO_0_23(VECTOR_3_DO_0_23),	
		.DO_0_24(VECTOR_3_DO_0_24),	
		.DO_0_25(VECTOR_3_DO_0_25),	
		.DO_0_26(VECTOR_3_DO_0_26),	
		.DO_0_27(VECTOR_3_DO_0_27),	
		.DO_0_28(VECTOR_3_DO_0_28),	
		.DO_0_29(VECTOR_3_DO_0_29),	
		.DO_0_30(VECTOR_3_DO_0_30),	
		.DO_0_31(VECTOR_3_DO_0_31),	
		.DO_0_32(VECTOR_3_DO_0_32),	
		.DO_0_33(VECTOR_3_DO_0_33),	
		.DO_0_34(VECTOR_3_DO_0_34),	
		.DO_0_35(VECTOR_3_DO_0_35),	
		.DO_0_36(VECTOR_3_DO_0_36),	
		.DO_0_37(VECTOR_3_DO_0_37),	
		.DO_0_38(VECTOR_3_DO_0_38),	
		.DO_0_39(VECTOR_3_DO_0_39),	
		.DO_0_40(VECTOR_3_DO_0_40),	
		.DO_0_41(VECTOR_3_DO_0_41),	
		.DO_0_42(VECTOR_3_DO_0_42),	
		.DO_0_43(VECTOR_3_DO_0_43),	
		.DO_0_44(VECTOR_3_DO_0_44),	
		.DO_0_45(VECTOR_3_DO_0_45),	
		.DO_0_46(VECTOR_3_DO_0_46),	
		.DO_0_47(VECTOR_3_DO_0_47),	
		.DO_0_48(VECTOR_3_DO_0_48),	
		.DO_0_49(VECTOR_3_DO_0_49),	
		.DO_0_50(VECTOR_3_DO_0_50),	
		.DO_0_51(VECTOR_3_DO_0_51),	
		.DO_0_52(VECTOR_3_DO_0_52),	
		.DO_0_53(VECTOR_3_DO_0_53),	
		.DO_0_54(VECTOR_3_DO_0_54),	
		.DO_0_55(VECTOR_3_DO_0_55),	
		.DO_0_56(VECTOR_3_DO_0_56),	
		.DO_0_57(VECTOR_3_DO_0_57),	
		.DO_0_58(VECTOR_3_DO_0_58),	
		.DO_0_59(VECTOR_3_DO_0_59),	
		.DO_0_60(VECTOR_3_DO_0_60),	
		.DO_0_61(VECTOR_3_DO_0_61),	
		.DO_0_62(VECTOR_3_DO_0_62),	
		.DO_0_63(VECTOR_3_DO_0_63),

		.DO_SUM(VECTOR_3_DO_SUM),

		.EN_DI_0_0(VECTOR_3_EN_DI_0_0),
		.EN_DI_0_1(VECTOR_3_EN_DI_0_1),
		.EN_DI_1_0(VECTOR_3_EN_DI_1_0),
		.EN_DI_1_1(VECTOR_3_EN_DI_1_1),
		.EN_DO_0_0(VECTOR_3_EN_DO_0_0),
		.EN_DO_0_1(VECTOR_3_EN_DO_0_1),

		.SEL_DI_0_R(VECTOR_3_SEL_DI_0_R),
		.SEL_DI_1_R(VECTOR_3_SEL_DI_1_R),
		.SEL_DO_0_R(VECTOR_3_SEL_DO_0_R),
		.SEL_DO_0_W(VECTOR_3_SEL_DO_0_W),
		.SEL_DO_SUM_PREC(VECTOR_3_SEL_DO_SUM_PREC),

		.SEL_OP(VECTOR_3_SEL_OP),
		.SEL_PREC(VECTOR_3_SEL_PREC),
		.SEL_BLOCK_LOAD(VECTOR_3_SEL_BLOCK_LOAD),

		.VECTOR_EN(VECTOR_3_VECTOR_EN),
		.VECTOR_LOAD_EN(VECTOR_3_VECTOR_LOAD_EN),
		.VECTOR_MODE(VECTOR_3_VECTOR_MODE),

		.CLK(CLK),
		.RSTn(RSTn)
	);


	wire	[31:0]	VECTOR_4_DI_0_00;
	wire	[31:0]	VECTOR_4_DI_0_01;
	wire	[31:0]	VECTOR_4_DI_0_02;
	wire	[31:0]	VECTOR_4_DI_0_03;
	wire	[31:0]	VECTOR_4_DI_0_04;
	wire	[31:0]	VECTOR_4_DI_0_05;
	wire	[31:0]	VECTOR_4_DI_0_06;
	wire	[31:0]	VECTOR_4_DI_0_07;
	wire	[31:0]	VECTOR_4_DI_0_08;
	wire	[31:0]	VECTOR_4_DI_0_09;
	wire	[31:0]	VECTOR_4_DI_0_10;
	wire	[31:0]	VECTOR_4_DI_0_11;
	wire	[31:0]	VECTOR_4_DI_0_12;
	wire	[31:0]	VECTOR_4_DI_0_13;
	wire	[31:0]	VECTOR_4_DI_0_14;
	wire	[31:0]	VECTOR_4_DI_0_15;
	wire	[31:0]	VECTOR_4_DI_0_16;
	wire	[31:0]	VECTOR_4_DI_0_17;
	wire	[31:0]	VECTOR_4_DI_0_18;
	wire	[31:0]	VECTOR_4_DI_0_19;
	wire	[31:0]	VECTOR_4_DI_0_20;
	wire	[31:0]	VECTOR_4_DI_0_21;
	wire	[31:0]	VECTOR_4_DI_0_22;
	wire	[31:0]	VECTOR_4_DI_0_23;
	wire	[31:0]	VECTOR_4_DI_0_24;
	wire	[31:0]	VECTOR_4_DI_0_25;
	wire	[31:0]	VECTOR_4_DI_0_26;
	wire	[31:0]	VECTOR_4_DI_0_27;
	wire	[31:0]	VECTOR_4_DI_0_28;
	wire	[31:0]	VECTOR_4_DI_0_29;
	wire	[31:0]	VECTOR_4_DI_0_30;
	wire	[31:0]	VECTOR_4_DI_0_31;
	wire	[31:0]	VECTOR_4_DI_0_32;
	wire	[31:0]	VECTOR_4_DI_0_33;
	wire	[31:0]	VECTOR_4_DI_0_34;
	wire	[31:0]	VECTOR_4_DI_0_35;
	wire	[31:0]	VECTOR_4_DI_0_36;
	wire	[31:0]	VECTOR_4_DI_0_37;
	wire	[31:0]	VECTOR_4_DI_0_38;
	wire	[31:0]	VECTOR_4_DI_0_39;
	wire	[31:0]	VECTOR_4_DI_0_40;
	wire	[31:0]	VECTOR_4_DI_0_41;
	wire	[31:0]	VECTOR_4_DI_0_42;
	wire	[31:0]	VECTOR_4_DI_0_43;
	wire	[31:0]	VECTOR_4_DI_0_44;
	wire	[31:0]	VECTOR_4_DI_0_45;
	wire	[31:0]	VECTOR_4_DI_0_46;
	wire	[31:0]	VECTOR_4_DI_0_47;
	wire	[31:0]	VECTOR_4_DI_0_48;
	wire	[31:0]	VECTOR_4_DI_0_49;
	wire	[31:0]	VECTOR_4_DI_0_50;
	wire	[31:0]	VECTOR_4_DI_0_51;
	wire	[31:0]	VECTOR_4_DI_0_52;
	wire	[31:0]	VECTOR_4_DI_0_53;
	wire	[31:0]	VECTOR_4_DI_0_54;
	wire	[31:0]	VECTOR_4_DI_0_55;
	wire	[31:0]	VECTOR_4_DI_0_56;
	wire	[31:0]	VECTOR_4_DI_0_57;
	wire	[31:0]	VECTOR_4_DI_0_58;
	wire	[31:0]	VECTOR_4_DI_0_59;
	wire	[31:0]	VECTOR_4_DI_0_60;
	wire	[31:0]	VECTOR_4_DI_0_61;
	wire	[31:0]	VECTOR_4_DI_0_62;
	wire	[31:0]	VECTOR_4_DI_0_63;
	
	wire	[31:0]	VECTOR_4_DO_0_00;
	wire	[31:0]	VECTOR_4_DO_0_01;
	wire	[31:0]	VECTOR_4_DO_0_02;
	wire	[31:0]	VECTOR_4_DO_0_03;
	wire	[31:0]	VECTOR_4_DO_0_04;
	wire	[31:0]	VECTOR_4_DO_0_05;
	wire	[31:0]	VECTOR_4_DO_0_06;
	wire	[31:0]	VECTOR_4_DO_0_07;
	wire	[31:0]	VECTOR_4_DO_0_08;
	wire	[31:0]	VECTOR_4_DO_0_09;
	wire	[31:0]	VECTOR_4_DO_0_10;
	wire	[31:0]	VECTOR_4_DO_0_11;
	wire	[31:0]	VECTOR_4_DO_0_12;
	wire	[31:0]	VECTOR_4_DO_0_13;
	wire	[31:0]	VECTOR_4_DO_0_14;
	wire	[31:0]	VECTOR_4_DO_0_15;
	wire	[31:0]	VECTOR_4_DO_0_16;
	wire	[31:0]	VECTOR_4_DO_0_17;
	wire	[31:0]	VECTOR_4_DO_0_18;
	wire	[31:0]	VECTOR_4_DO_0_19;
	wire	[31:0]	VECTOR_4_DO_0_20;
	wire	[31:0]	VECTOR_4_DO_0_21;
	wire	[31:0]	VECTOR_4_DO_0_22;
	wire	[31:0]	VECTOR_4_DO_0_23;
	wire	[31:0]	VECTOR_4_DO_0_24;
	wire	[31:0]	VECTOR_4_DO_0_25;
	wire	[31:0]	VECTOR_4_DO_0_26;
	wire	[31:0]	VECTOR_4_DO_0_27;
	wire	[31:0]	VECTOR_4_DO_0_28;
	wire	[31:0]	VECTOR_4_DO_0_29;
	wire	[31:0]	VECTOR_4_DO_0_30;
	wire	[31:0]	VECTOR_4_DO_0_31;
	wire	[31:0]	VECTOR_4_DO_0_32;
	wire	[31:0]	VECTOR_4_DO_0_33;
	wire	[31:0]	VECTOR_4_DO_0_34;
	wire	[31:0]	VECTOR_4_DO_0_35;
	wire	[31:0]	VECTOR_4_DO_0_36;
	wire	[31:0]	VECTOR_4_DO_0_37;
	wire	[31:0]	VECTOR_4_DO_0_38;
	wire	[31:0]	VECTOR_4_DO_0_39;
	wire	[31:0]	VECTOR_4_DO_0_40;
	wire	[31:0]	VECTOR_4_DO_0_41;
	wire	[31:0]	VECTOR_4_DO_0_42;
	wire	[31:0]	VECTOR_4_DO_0_43;
	wire	[31:0]	VECTOR_4_DO_0_44;
	wire	[31:0]	VECTOR_4_DO_0_45;
	wire	[31:0]	VECTOR_4_DO_0_46;
	wire	[31:0]	VECTOR_4_DO_0_47;
	wire	[31:0]	VECTOR_4_DO_0_48;
	wire	[31:0]	VECTOR_4_DO_0_49;
	wire	[31:0]	VECTOR_4_DO_0_50;
	wire	[31:0]	VECTOR_4_DO_0_51;
	wire	[31:0]	VECTOR_4_DO_0_52;
	wire	[31:0]	VECTOR_4_DO_0_53;
	wire	[31:0]	VECTOR_4_DO_0_54;
	wire	[31:0]	VECTOR_4_DO_0_55;
	wire	[31:0]	VECTOR_4_DO_0_56;
	wire	[31:0]	VECTOR_4_DO_0_57;
	wire	[31:0]	VECTOR_4_DO_0_58;
	wire	[31:0]	VECTOR_4_DO_0_59;
	wire	[31:0]	VECTOR_4_DO_0_60;
	wire	[31:0]	VECTOR_4_DO_0_61;
	wire	[31:0]	VECTOR_4_DO_0_62;
	wire	[31:0]	VECTOR_4_DO_0_63;

	wire	[31:0]	VECTOR_4_DO_SUM;

	wire		VECTOR_4_EN_DI_0_0;
	wire		VECTOR_4_EN_DI_0_1;
	wire		VECTOR_4_EN_DI_1_0;
	wire		VECTOR_4_EN_DI_1_1;
	wire		VECTOR_4_EN_DO_0_0;
	wire		VECTOR_4_EN_DO_0_1;

	wire		VECTOR_4_SEL_DI_0_R;
	wire		VECTOR_4_SEL_DI_1_R;
	wire		VECTOR_4_SEL_DO_0_R;
	wire		VECTOR_4_SEL_DO_0_W;
	wire		VECTOR_4_SEL_DO_SUM_PREC;

	wire	[1:0]	VECTOR_4_SEL_OP;
	wire		VECTOR_4_SEL_PREC;
	wire	[2:0]	VECTOR_4_SEL_BLOCK_LOAD;

	wire		VECTOR_4_VECTOR_EN;
	wire		VECTOR_4_VECTOR_LOAD_EN;
	wire	[1:0]	VECTOR_4_VECTOR_MODE;
	
	
	VECTOR vector_4 (
		.DI_0_00(VECTOR_4_DI_0_00),	
		.DI_0_01(VECTOR_4_DI_0_01),	
		.DI_0_02(VECTOR_4_DI_0_02),	
		.DI_0_03(VECTOR_4_DI_0_03),	
		.DI_0_04(VECTOR_4_DI_0_04),	
		.DI_0_05(VECTOR_4_DI_0_05),	
		.DI_0_06(VECTOR_4_DI_0_06),	
		.DI_0_07(VECTOR_4_DI_0_07),	
		.DI_0_08(VECTOR_4_DI_0_08),	
		.DI_0_09(VECTOR_4_DI_0_09),	
		.DI_0_10(VECTOR_4_DI_0_10),	
		.DI_0_11(VECTOR_4_DI_0_11),	
		.DI_0_12(VECTOR_4_DI_0_12),	
		.DI_0_13(VECTOR_4_DI_0_13),	
		.DI_0_14(VECTOR_4_DI_0_14),	
		.DI_0_15(VECTOR_4_DI_0_15),	
		.DI_0_16(VECTOR_4_DI_0_16),	
		.DI_0_17(VECTOR_4_DI_0_17),	
		.DI_0_18(VECTOR_4_DI_0_18),	
		.DI_0_19(VECTOR_4_DI_0_19),	
		.DI_0_20(VECTOR_4_DI_0_20),	
		.DI_0_21(VECTOR_4_DI_0_21),	
		.DI_0_22(VECTOR_4_DI_0_22),	
		.DI_0_23(VECTOR_4_DI_0_23),	
		.DI_0_24(VECTOR_4_DI_0_24),	
		.DI_0_25(VECTOR_4_DI_0_25),	
		.DI_0_26(VECTOR_4_DI_0_26),	
		.DI_0_27(VECTOR_4_DI_0_27),	
		.DI_0_28(VECTOR_4_DI_0_28),	
		.DI_0_29(VECTOR_4_DI_0_29),	
		.DI_0_30(VECTOR_4_DI_0_30),	
		.DI_0_31(VECTOR_4_DI_0_31),	
		.DI_0_32(VECTOR_4_DI_0_32),	
		.DI_0_33(VECTOR_4_DI_0_33),	
		.DI_0_34(VECTOR_4_DI_0_34),	
		.DI_0_35(VECTOR_4_DI_0_35),	
		.DI_0_36(VECTOR_4_DI_0_36),	
		.DI_0_37(VECTOR_4_DI_0_37),	
		.DI_0_38(VECTOR_4_DI_0_38),	
		.DI_0_39(VECTOR_4_DI_0_39),	
		.DI_0_40(VECTOR_4_DI_0_40),	
		.DI_0_41(VECTOR_4_DI_0_41),	
		.DI_0_42(VECTOR_4_DI_0_42),	
		.DI_0_43(VECTOR_4_DI_0_43),	
		.DI_0_44(VECTOR_4_DI_0_44),	
		.DI_0_45(VECTOR_4_DI_0_45),	
		.DI_0_46(VECTOR_4_DI_0_46),	
		.DI_0_47(VECTOR_4_DI_0_47),	
		.DI_0_48(VECTOR_4_DI_0_48),	
		.DI_0_49(VECTOR_4_DI_0_49),	
		.DI_0_50(VECTOR_4_DI_0_50),	
		.DI_0_51(VECTOR_4_DI_0_51),	
		.DI_0_52(VECTOR_4_DI_0_52),	
		.DI_0_53(VECTOR_4_DI_0_53),	
		.DI_0_54(VECTOR_4_DI_0_54),	
		.DI_0_55(VECTOR_4_DI_0_55),	
		.DI_0_56(VECTOR_4_DI_0_56),	
		.DI_0_57(VECTOR_4_DI_0_57),	
		.DI_0_58(VECTOR_4_DI_0_58),	
		.DI_0_59(VECTOR_4_DI_0_59),	
		.DI_0_60(VECTOR_4_DI_0_60),	
		.DI_0_61(VECTOR_4_DI_0_61),	
		.DI_0_62(VECTOR_4_DI_0_62),	
		.DI_0_63(VECTOR_4_DI_0_63),	
		
		.DO_0_00(VECTOR_4_DO_0_00),	
		.DO_0_01(VECTOR_4_DO_0_01),	
		.DO_0_02(VECTOR_4_DO_0_02),	
		.DO_0_03(VECTOR_4_DO_0_03),	
		.DO_0_04(VECTOR_4_DO_0_04),	
		.DO_0_05(VECTOR_4_DO_0_05),	
		.DO_0_06(VECTOR_4_DO_0_06),	
		.DO_0_07(VECTOR_4_DO_0_07),	
		.DO_0_08(VECTOR_4_DO_0_08),	
		.DO_0_09(VECTOR_4_DO_0_09),	
		.DO_0_10(VECTOR_4_DO_0_10),	
		.DO_0_11(VECTOR_4_DO_0_11),	
		.DO_0_12(VECTOR_4_DO_0_12),	
		.DO_0_13(VECTOR_4_DO_0_13),	
		.DO_0_14(VECTOR_4_DO_0_14),	
		.DO_0_15(VECTOR_4_DO_0_15),	
		.DO_0_16(VECTOR_4_DO_0_16),	
		.DO_0_17(VECTOR_4_DO_0_17),	
		.DO_0_18(VECTOR_4_DO_0_18),	
		.DO_0_19(VECTOR_4_DO_0_19),	
		.DO_0_20(VECTOR_4_DO_0_20),	
		.DO_0_21(VECTOR_4_DO_0_21),	
		.DO_0_22(VECTOR_4_DO_0_22),	
		.DO_0_23(VECTOR_4_DO_0_23),	
		.DO_0_24(VECTOR_4_DO_0_24),	
		.DO_0_25(VECTOR_4_DO_0_25),	
		.DO_0_26(VECTOR_4_DO_0_26),	
		.DO_0_27(VECTOR_4_DO_0_27),	
		.DO_0_28(VECTOR_4_DO_0_28),	
		.DO_0_29(VECTOR_4_DO_0_29),	
		.DO_0_30(VECTOR_4_DO_0_30),	
		.DO_0_31(VECTOR_4_DO_0_31),	
		.DO_0_32(VECTOR_4_DO_0_32),	
		.DO_0_33(VECTOR_4_DO_0_33),	
		.DO_0_34(VECTOR_4_DO_0_34),	
		.DO_0_35(VECTOR_4_DO_0_35),	
		.DO_0_36(VECTOR_4_DO_0_36),	
		.DO_0_37(VECTOR_4_DO_0_37),	
		.DO_0_38(VECTOR_4_DO_0_38),	
		.DO_0_39(VECTOR_4_DO_0_39),	
		.DO_0_40(VECTOR_4_DO_0_40),	
		.DO_0_41(VECTOR_4_DO_0_41),	
		.DO_0_42(VECTOR_4_DO_0_42),	
		.DO_0_43(VECTOR_4_DO_0_43),	
		.DO_0_44(VECTOR_4_DO_0_44),	
		.DO_0_45(VECTOR_4_DO_0_45),	
		.DO_0_46(VECTOR_4_DO_0_46),	
		.DO_0_47(VECTOR_4_DO_0_47),	
		.DO_0_48(VECTOR_4_DO_0_48),	
		.DO_0_49(VECTOR_4_DO_0_49),	
		.DO_0_50(VECTOR_4_DO_0_50),	
		.DO_0_51(VECTOR_4_DO_0_51),	
		.DO_0_52(VECTOR_4_DO_0_52),	
		.DO_0_53(VECTOR_4_DO_0_53),	
		.DO_0_54(VECTOR_4_DO_0_54),	
		.DO_0_55(VECTOR_4_DO_0_55),	
		.DO_0_56(VECTOR_4_DO_0_56),	
		.DO_0_57(VECTOR_4_DO_0_57),	
		.DO_0_58(VECTOR_4_DO_0_58),	
		.DO_0_59(VECTOR_4_DO_0_59),	
		.DO_0_60(VECTOR_4_DO_0_60),	
		.DO_0_61(VECTOR_4_DO_0_61),	
		.DO_0_62(VECTOR_4_DO_0_62),	
		.DO_0_63(VECTOR_4_DO_0_63),

		.DO_SUM(VECTOR_4_DO_SUM),

		.EN_DI_0_0(VECTOR_4_EN_DI_0_0),
		.EN_DI_0_1(VECTOR_4_EN_DI_0_1),
		.EN_DI_1_0(VECTOR_4_EN_DI_1_0),
		.EN_DI_1_1(VECTOR_4_EN_DI_1_1),
		.EN_DO_0_0(VECTOR_4_EN_DO_0_0),
		.EN_DO_0_1(VECTOR_4_EN_DO_0_1),

		.SEL_DI_0_R(VECTOR_4_SEL_DI_0_R),
		.SEL_DI_1_R(VECTOR_4_SEL_DI_1_R),
		.SEL_DO_0_R(VECTOR_4_SEL_DO_0_R),
		.SEL_DO_0_W(VECTOR_4_SEL_DO_0_W),
		.SEL_DO_SUM_PREC(VECTOR_4_SEL_DO_SUM_PREC),

		.SEL_OP(VECTOR_4_SEL_OP),
		.SEL_PREC(VECTOR_4_SEL_PREC),
		.SEL_BLOCK_LOAD(VECTOR_4_SEL_BLOCK_LOAD),

		.VECTOR_EN(VECTOR_4_VECTOR_EN),
		.VECTOR_LOAD_EN(VECTOR_4_VECTOR_LOAD_EN),
		.VECTOR_MODE(VECTOR_4_VECTOR_MODE),

		.CLK(CLK),
		.RSTn(RSTn)
	);


	wire	[31:0]	VECTOR_5_DI_0_00;
	wire	[31:0]	VECTOR_5_DI_0_01;
	wire	[31:0]	VECTOR_5_DI_0_02;
	wire	[31:0]	VECTOR_5_DI_0_03;
	wire	[31:0]	VECTOR_5_DI_0_04;
	wire	[31:0]	VECTOR_5_DI_0_05;
	wire	[31:0]	VECTOR_5_DI_0_06;
	wire	[31:0]	VECTOR_5_DI_0_07;
	wire	[31:0]	VECTOR_5_DI_0_08;
	wire	[31:0]	VECTOR_5_DI_0_09;
	wire	[31:0]	VECTOR_5_DI_0_10;
	wire	[31:0]	VECTOR_5_DI_0_11;
	wire	[31:0]	VECTOR_5_DI_0_12;
	wire	[31:0]	VECTOR_5_DI_0_13;
	wire	[31:0]	VECTOR_5_DI_0_14;
	wire	[31:0]	VECTOR_5_DI_0_15;
	wire	[31:0]	VECTOR_5_DI_0_16;
	wire	[31:0]	VECTOR_5_DI_0_17;
	wire	[31:0]	VECTOR_5_DI_0_18;
	wire	[31:0]	VECTOR_5_DI_0_19;
	wire	[31:0]	VECTOR_5_DI_0_20;
	wire	[31:0]	VECTOR_5_DI_0_21;
	wire	[31:0]	VECTOR_5_DI_0_22;
	wire	[31:0]	VECTOR_5_DI_0_23;
	wire	[31:0]	VECTOR_5_DI_0_24;
	wire	[31:0]	VECTOR_5_DI_0_25;
	wire	[31:0]	VECTOR_5_DI_0_26;
	wire	[31:0]	VECTOR_5_DI_0_27;
	wire	[31:0]	VECTOR_5_DI_0_28;
	wire	[31:0]	VECTOR_5_DI_0_29;
	wire	[31:0]	VECTOR_5_DI_0_30;
	wire	[31:0]	VECTOR_5_DI_0_31;
	wire	[31:0]	VECTOR_5_DI_0_32;
	wire	[31:0]	VECTOR_5_DI_0_33;
	wire	[31:0]	VECTOR_5_DI_0_34;
	wire	[31:0]	VECTOR_5_DI_0_35;
	wire	[31:0]	VECTOR_5_DI_0_36;
	wire	[31:0]	VECTOR_5_DI_0_37;
	wire	[31:0]	VECTOR_5_DI_0_38;
	wire	[31:0]	VECTOR_5_DI_0_39;
	wire	[31:0]	VECTOR_5_DI_0_40;
	wire	[31:0]	VECTOR_5_DI_0_41;
	wire	[31:0]	VECTOR_5_DI_0_42;
	wire	[31:0]	VECTOR_5_DI_0_43;
	wire	[31:0]	VECTOR_5_DI_0_44;
	wire	[31:0]	VECTOR_5_DI_0_45;
	wire	[31:0]	VECTOR_5_DI_0_46;
	wire	[31:0]	VECTOR_5_DI_0_47;
	wire	[31:0]	VECTOR_5_DI_0_48;
	wire	[31:0]	VECTOR_5_DI_0_49;
	wire	[31:0]	VECTOR_5_DI_0_50;
	wire	[31:0]	VECTOR_5_DI_0_51;
	wire	[31:0]	VECTOR_5_DI_0_52;
	wire	[31:0]	VECTOR_5_DI_0_53;
	wire	[31:0]	VECTOR_5_DI_0_54;
	wire	[31:0]	VECTOR_5_DI_0_55;
	wire	[31:0]	VECTOR_5_DI_0_56;
	wire	[31:0]	VECTOR_5_DI_0_57;
	wire	[31:0]	VECTOR_5_DI_0_58;
	wire	[31:0]	VECTOR_5_DI_0_59;
	wire	[31:0]	VECTOR_5_DI_0_60;
	wire	[31:0]	VECTOR_5_DI_0_61;
	wire	[31:0]	VECTOR_5_DI_0_62;
	wire	[31:0]	VECTOR_5_DI_0_63;
	
	wire	[31:0]	VECTOR_5_DO_0_00;
	wire	[31:0]	VECTOR_5_DO_0_01;
	wire	[31:0]	VECTOR_5_DO_0_02;
	wire	[31:0]	VECTOR_5_DO_0_03;
	wire	[31:0]	VECTOR_5_DO_0_04;
	wire	[31:0]	VECTOR_5_DO_0_05;
	wire	[31:0]	VECTOR_5_DO_0_06;
	wire	[31:0]	VECTOR_5_DO_0_07;
	wire	[31:0]	VECTOR_5_DO_0_08;
	wire	[31:0]	VECTOR_5_DO_0_09;
	wire	[31:0]	VECTOR_5_DO_0_10;
	wire	[31:0]	VECTOR_5_DO_0_11;
	wire	[31:0]	VECTOR_5_DO_0_12;
	wire	[31:0]	VECTOR_5_DO_0_13;
	wire	[31:0]	VECTOR_5_DO_0_14;
	wire	[31:0]	VECTOR_5_DO_0_15;
	wire	[31:0]	VECTOR_5_DO_0_16;
	wire	[31:0]	VECTOR_5_DO_0_17;
	wire	[31:0]	VECTOR_5_DO_0_18;
	wire	[31:0]	VECTOR_5_DO_0_19;
	wire	[31:0]	VECTOR_5_DO_0_20;
	wire	[31:0]	VECTOR_5_DO_0_21;
	wire	[31:0]	VECTOR_5_DO_0_22;
	wire	[31:0]	VECTOR_5_DO_0_23;
	wire	[31:0]	VECTOR_5_DO_0_24;
	wire	[31:0]	VECTOR_5_DO_0_25;
	wire	[31:0]	VECTOR_5_DO_0_26;
	wire	[31:0]	VECTOR_5_DO_0_27;
	wire	[31:0]	VECTOR_5_DO_0_28;
	wire	[31:0]	VECTOR_5_DO_0_29;
	wire	[31:0]	VECTOR_5_DO_0_30;
	wire	[31:0]	VECTOR_5_DO_0_31;
	wire	[31:0]	VECTOR_5_DO_0_32;
	wire	[31:0]	VECTOR_5_DO_0_33;
	wire	[31:0]	VECTOR_5_DO_0_34;
	wire	[31:0]	VECTOR_5_DO_0_35;
	wire	[31:0]	VECTOR_5_DO_0_36;
	wire	[31:0]	VECTOR_5_DO_0_37;
	wire	[31:0]	VECTOR_5_DO_0_38;
	wire	[31:0]	VECTOR_5_DO_0_39;
	wire	[31:0]	VECTOR_5_DO_0_40;
	wire	[31:0]	VECTOR_5_DO_0_41;
	wire	[31:0]	VECTOR_5_DO_0_42;
	wire	[31:0]	VECTOR_5_DO_0_43;
	wire	[31:0]	VECTOR_5_DO_0_44;
	wire	[31:0]	VECTOR_5_DO_0_45;
	wire	[31:0]	VECTOR_5_DO_0_46;
	wire	[31:0]	VECTOR_5_DO_0_47;
	wire	[31:0]	VECTOR_5_DO_0_48;
	wire	[31:0]	VECTOR_5_DO_0_49;
	wire	[31:0]	VECTOR_5_DO_0_50;
	wire	[31:0]	VECTOR_5_DO_0_51;
	wire	[31:0]	VECTOR_5_DO_0_52;
	wire	[31:0]	VECTOR_5_DO_0_53;
	wire	[31:0]	VECTOR_5_DO_0_54;
	wire	[31:0]	VECTOR_5_DO_0_55;
	wire	[31:0]	VECTOR_5_DO_0_56;
	wire	[31:0]	VECTOR_5_DO_0_57;
	wire	[31:0]	VECTOR_5_DO_0_58;
	wire	[31:0]	VECTOR_5_DO_0_59;
	wire	[31:0]	VECTOR_5_DO_0_60;
	wire	[31:0]	VECTOR_5_DO_0_61;
	wire	[31:0]	VECTOR_5_DO_0_62;
	wire	[31:0]	VECTOR_5_DO_0_63;

	wire	[31:0]	VECTOR_5_DO_SUM;

	wire		VECTOR_5_EN_DI_0_0;
	wire		VECTOR_5_EN_DI_0_1;
	wire		VECTOR_5_EN_DI_1_0;
	wire		VECTOR_5_EN_DI_1_1;
	wire		VECTOR_5_EN_DO_0_0;
	wire		VECTOR_5_EN_DO_0_1;

	wire		VECTOR_5_SEL_DI_0_R;
	wire		VECTOR_5_SEL_DI_1_R;
	wire		VECTOR_5_SEL_DO_0_R;
	wire		VECTOR_5_SEL_DO_0_W;
	wire		VECTOR_5_SEL_DO_SUM_PREC;

	wire	[1:0]	VECTOR_5_SEL_OP;
	wire		VECTOR_5_SEL_PREC;
	wire	[2:0]	VECTOR_5_SEL_BLOCK_LOAD;

	wire		VECTOR_5_VECTOR_EN;
	wire		VECTOR_5_VECTOR_LOAD_EN;
	wire	[1:0]	VECTOR_5_VECTOR_MODE;
	
	
	VECTOR vector_5 (
		.DI_0_00(VECTOR_5_DI_0_00),	
		.DI_0_01(VECTOR_5_DI_0_01),	
		.DI_0_02(VECTOR_5_DI_0_02),	
		.DI_0_03(VECTOR_5_DI_0_03),	
		.DI_0_04(VECTOR_5_DI_0_04),	
		.DI_0_05(VECTOR_5_DI_0_05),	
		.DI_0_06(VECTOR_5_DI_0_06),	
		.DI_0_07(VECTOR_5_DI_0_07),	
		.DI_0_08(VECTOR_5_DI_0_08),	
		.DI_0_09(VECTOR_5_DI_0_09),	
		.DI_0_10(VECTOR_5_DI_0_10),	
		.DI_0_11(VECTOR_5_DI_0_11),	
		.DI_0_12(VECTOR_5_DI_0_12),	
		.DI_0_13(VECTOR_5_DI_0_13),	
		.DI_0_14(VECTOR_5_DI_0_14),	
		.DI_0_15(VECTOR_5_DI_0_15),	
		.DI_0_16(VECTOR_5_DI_0_16),	
		.DI_0_17(VECTOR_5_DI_0_17),	
		.DI_0_18(VECTOR_5_DI_0_18),	
		.DI_0_19(VECTOR_5_DI_0_19),	
		.DI_0_20(VECTOR_5_DI_0_20),	
		.DI_0_21(VECTOR_5_DI_0_21),	
		.DI_0_22(VECTOR_5_DI_0_22),	
		.DI_0_23(VECTOR_5_DI_0_23),	
		.DI_0_24(VECTOR_5_DI_0_24),	
		.DI_0_25(VECTOR_5_DI_0_25),	
		.DI_0_26(VECTOR_5_DI_0_26),	
		.DI_0_27(VECTOR_5_DI_0_27),	
		.DI_0_28(VECTOR_5_DI_0_28),	
		.DI_0_29(VECTOR_5_DI_0_29),	
		.DI_0_30(VECTOR_5_DI_0_30),	
		.DI_0_31(VECTOR_5_DI_0_31),	
		.DI_0_32(VECTOR_5_DI_0_32),	
		.DI_0_33(VECTOR_5_DI_0_33),	
		.DI_0_34(VECTOR_5_DI_0_34),	
		.DI_0_35(VECTOR_5_DI_0_35),	
		.DI_0_36(VECTOR_5_DI_0_36),	
		.DI_0_37(VECTOR_5_DI_0_37),	
		.DI_0_38(VECTOR_5_DI_0_38),	
		.DI_0_39(VECTOR_5_DI_0_39),	
		.DI_0_40(VECTOR_5_DI_0_40),	
		.DI_0_41(VECTOR_5_DI_0_41),	
		.DI_0_42(VECTOR_5_DI_0_42),	
		.DI_0_43(VECTOR_5_DI_0_43),	
		.DI_0_44(VECTOR_5_DI_0_44),	
		.DI_0_45(VECTOR_5_DI_0_45),	
		.DI_0_46(VECTOR_5_DI_0_46),	
		.DI_0_47(VECTOR_5_DI_0_47),	
		.DI_0_48(VECTOR_5_DI_0_48),	
		.DI_0_49(VECTOR_5_DI_0_49),	
		.DI_0_50(VECTOR_5_DI_0_50),	
		.DI_0_51(VECTOR_5_DI_0_51),	
		.DI_0_52(VECTOR_5_DI_0_52),	
		.DI_0_53(VECTOR_5_DI_0_53),	
		.DI_0_54(VECTOR_5_DI_0_54),	
		.DI_0_55(VECTOR_5_DI_0_55),	
		.DI_0_56(VECTOR_5_DI_0_56),	
		.DI_0_57(VECTOR_5_DI_0_57),	
		.DI_0_58(VECTOR_5_DI_0_58),	
		.DI_0_59(VECTOR_5_DI_0_59),	
		.DI_0_60(VECTOR_5_DI_0_60),	
		.DI_0_61(VECTOR_5_DI_0_61),	
		.DI_0_62(VECTOR_5_DI_0_62),	
		.DI_0_63(VECTOR_5_DI_0_63),	
		
		.DO_0_00(VECTOR_5_DO_0_00),	
		.DO_0_01(VECTOR_5_DO_0_01),	
		.DO_0_02(VECTOR_5_DO_0_02),	
		.DO_0_03(VECTOR_5_DO_0_03),	
		.DO_0_04(VECTOR_5_DO_0_04),	
		.DO_0_05(VECTOR_5_DO_0_05),	
		.DO_0_06(VECTOR_5_DO_0_06),	
		.DO_0_07(VECTOR_5_DO_0_07),	
		.DO_0_08(VECTOR_5_DO_0_08),	
		.DO_0_09(VECTOR_5_DO_0_09),	
		.DO_0_10(VECTOR_5_DO_0_10),	
		.DO_0_11(VECTOR_5_DO_0_11),	
		.DO_0_12(VECTOR_5_DO_0_12),	
		.DO_0_13(VECTOR_5_DO_0_13),	
		.DO_0_14(VECTOR_5_DO_0_14),	
		.DO_0_15(VECTOR_5_DO_0_15),	
		.DO_0_16(VECTOR_5_DO_0_16),	
		.DO_0_17(VECTOR_5_DO_0_17),	
		.DO_0_18(VECTOR_5_DO_0_18),	
		.DO_0_19(VECTOR_5_DO_0_19),	
		.DO_0_20(VECTOR_5_DO_0_20),	
		.DO_0_21(VECTOR_5_DO_0_21),	
		.DO_0_22(VECTOR_5_DO_0_22),	
		.DO_0_23(VECTOR_5_DO_0_23),	
		.DO_0_24(VECTOR_5_DO_0_24),	
		.DO_0_25(VECTOR_5_DO_0_25),	
		.DO_0_26(VECTOR_5_DO_0_26),	
		.DO_0_27(VECTOR_5_DO_0_27),	
		.DO_0_28(VECTOR_5_DO_0_28),	
		.DO_0_29(VECTOR_5_DO_0_29),	
		.DO_0_30(VECTOR_5_DO_0_30),	
		.DO_0_31(VECTOR_5_DO_0_31),	
		.DO_0_32(VECTOR_5_DO_0_32),	
		.DO_0_33(VECTOR_5_DO_0_33),	
		.DO_0_34(VECTOR_5_DO_0_34),	
		.DO_0_35(VECTOR_5_DO_0_35),	
		.DO_0_36(VECTOR_5_DO_0_36),	
		.DO_0_37(VECTOR_5_DO_0_37),	
		.DO_0_38(VECTOR_5_DO_0_38),	
		.DO_0_39(VECTOR_5_DO_0_39),	
		.DO_0_40(VECTOR_5_DO_0_40),	
		.DO_0_41(VECTOR_5_DO_0_41),	
		.DO_0_42(VECTOR_5_DO_0_42),	
		.DO_0_43(VECTOR_5_DO_0_43),	
		.DO_0_44(VECTOR_5_DO_0_44),	
		.DO_0_45(VECTOR_5_DO_0_45),	
		.DO_0_46(VECTOR_5_DO_0_46),	
		.DO_0_47(VECTOR_5_DO_0_47),	
		.DO_0_48(VECTOR_5_DO_0_48),	
		.DO_0_49(VECTOR_5_DO_0_49),	
		.DO_0_50(VECTOR_5_DO_0_50),	
		.DO_0_51(VECTOR_5_DO_0_51),	
		.DO_0_52(VECTOR_5_DO_0_52),	
		.DO_0_53(VECTOR_5_DO_0_53),	
		.DO_0_54(VECTOR_5_DO_0_54),	
		.DO_0_55(VECTOR_5_DO_0_55),	
		.DO_0_56(VECTOR_5_DO_0_56),	
		.DO_0_57(VECTOR_5_DO_0_57),	
		.DO_0_58(VECTOR_5_DO_0_58),	
		.DO_0_59(VECTOR_5_DO_0_59),	
		.DO_0_60(VECTOR_5_DO_0_60),	
		.DO_0_61(VECTOR_5_DO_0_61),	
		.DO_0_62(VECTOR_5_DO_0_62),	
		.DO_0_63(VECTOR_5_DO_0_63),

		.DO_SUM(VECTOR_5_DO_SUM),

		.EN_DI_0_0(VECTOR_5_EN_DI_0_0),
		.EN_DI_0_1(VECTOR_5_EN_DI_0_1),
		.EN_DI_1_0(VECTOR_5_EN_DI_1_0),
		.EN_DI_1_1(VECTOR_5_EN_DI_1_1),
		.EN_DO_0_0(VECTOR_5_EN_DO_0_0),
		.EN_DO_0_1(VECTOR_5_EN_DO_0_1),

		.SEL_DI_0_R(VECTOR_5_SEL_DI_0_R),
		.SEL_DI_1_R(VECTOR_5_SEL_DI_1_R),
		.SEL_DO_0_R(VECTOR_5_SEL_DO_0_R),
		.SEL_DO_0_W(VECTOR_5_SEL_DO_0_W),
		.SEL_DO_SUM_PREC(VECTOR_5_SEL_DO_SUM_PREC),

		.SEL_OP(VECTOR_5_SEL_OP),
		.SEL_PREC(VECTOR_5_SEL_PREC),
		.SEL_BLOCK_LOAD(VECTOR_5_SEL_BLOCK_LOAD),

		.VECTOR_EN(VECTOR_5_VECTOR_EN),
		.VECTOR_LOAD_EN(VECTOR_5_VECTOR_LOAD_EN),
		.VECTOR_MODE(VECTOR_5_VECTOR_MODE),

		.CLK(CLK),
		.RSTn(RSTn)
	);


	wire	[31:0]	VECTOR_6_DI_0_00;
	wire	[31:0]	VECTOR_6_DI_0_01;
	wire	[31:0]	VECTOR_6_DI_0_02;
	wire	[31:0]	VECTOR_6_DI_0_03;
	wire	[31:0]	VECTOR_6_DI_0_04;
	wire	[31:0]	VECTOR_6_DI_0_05;
	wire	[31:0]	VECTOR_6_DI_0_06;
	wire	[31:0]	VECTOR_6_DI_0_07;
	wire	[31:0]	VECTOR_6_DI_0_08;
	wire	[31:0]	VECTOR_6_DI_0_09;
	wire	[31:0]	VECTOR_6_DI_0_10;
	wire	[31:0]	VECTOR_6_DI_0_11;
	wire	[31:0]	VECTOR_6_DI_0_12;
	wire	[31:0]	VECTOR_6_DI_0_13;
	wire	[31:0]	VECTOR_6_DI_0_14;
	wire	[31:0]	VECTOR_6_DI_0_15;
	wire	[31:0]	VECTOR_6_DI_0_16;
	wire	[31:0]	VECTOR_6_DI_0_17;
	wire	[31:0]	VECTOR_6_DI_0_18;
	wire	[31:0]	VECTOR_6_DI_0_19;
	wire	[31:0]	VECTOR_6_DI_0_20;
	wire	[31:0]	VECTOR_6_DI_0_21;
	wire	[31:0]	VECTOR_6_DI_0_22;
	wire	[31:0]	VECTOR_6_DI_0_23;
	wire	[31:0]	VECTOR_6_DI_0_24;
	wire	[31:0]	VECTOR_6_DI_0_25;
	wire	[31:0]	VECTOR_6_DI_0_26;
	wire	[31:0]	VECTOR_6_DI_0_27;
	wire	[31:0]	VECTOR_6_DI_0_28;
	wire	[31:0]	VECTOR_6_DI_0_29;
	wire	[31:0]	VECTOR_6_DI_0_30;
	wire	[31:0]	VECTOR_6_DI_0_31;
	wire	[31:0]	VECTOR_6_DI_0_32;
	wire	[31:0]	VECTOR_6_DI_0_33;
	wire	[31:0]	VECTOR_6_DI_0_34;
	wire	[31:0]	VECTOR_6_DI_0_35;
	wire	[31:0]	VECTOR_6_DI_0_36;
	wire	[31:0]	VECTOR_6_DI_0_37;
	wire	[31:0]	VECTOR_6_DI_0_38;
	wire	[31:0]	VECTOR_6_DI_0_39;
	wire	[31:0]	VECTOR_6_DI_0_40;
	wire	[31:0]	VECTOR_6_DI_0_41;
	wire	[31:0]	VECTOR_6_DI_0_42;
	wire	[31:0]	VECTOR_6_DI_0_43;
	wire	[31:0]	VECTOR_6_DI_0_44;
	wire	[31:0]	VECTOR_6_DI_0_45;
	wire	[31:0]	VECTOR_6_DI_0_46;
	wire	[31:0]	VECTOR_6_DI_0_47;
	wire	[31:0]	VECTOR_6_DI_0_48;
	wire	[31:0]	VECTOR_6_DI_0_49;
	wire	[31:0]	VECTOR_6_DI_0_50;
	wire	[31:0]	VECTOR_6_DI_0_51;
	wire	[31:0]	VECTOR_6_DI_0_52;
	wire	[31:0]	VECTOR_6_DI_0_53;
	wire	[31:0]	VECTOR_6_DI_0_54;
	wire	[31:0]	VECTOR_6_DI_0_55;
	wire	[31:0]	VECTOR_6_DI_0_56;
	wire	[31:0]	VECTOR_6_DI_0_57;
	wire	[31:0]	VECTOR_6_DI_0_58;
	wire	[31:0]	VECTOR_6_DI_0_59;
	wire	[31:0]	VECTOR_6_DI_0_60;
	wire	[31:0]	VECTOR_6_DI_0_61;
	wire	[31:0]	VECTOR_6_DI_0_62;
	wire	[31:0]	VECTOR_6_DI_0_63;
	
	wire	[31:0]	VECTOR_6_DO_0_00;
	wire	[31:0]	VECTOR_6_DO_0_01;
	wire	[31:0]	VECTOR_6_DO_0_02;
	wire	[31:0]	VECTOR_6_DO_0_03;
	wire	[31:0]	VECTOR_6_DO_0_04;
	wire	[31:0]	VECTOR_6_DO_0_05;
	wire	[31:0]	VECTOR_6_DO_0_06;
	wire	[31:0]	VECTOR_6_DO_0_07;
	wire	[31:0]	VECTOR_6_DO_0_08;
	wire	[31:0]	VECTOR_6_DO_0_09;
	wire	[31:0]	VECTOR_6_DO_0_10;
	wire	[31:0]	VECTOR_6_DO_0_11;
	wire	[31:0]	VECTOR_6_DO_0_12;
	wire	[31:0]	VECTOR_6_DO_0_13;
	wire	[31:0]	VECTOR_6_DO_0_14;
	wire	[31:0]	VECTOR_6_DO_0_15;
	wire	[31:0]	VECTOR_6_DO_0_16;
	wire	[31:0]	VECTOR_6_DO_0_17;
	wire	[31:0]	VECTOR_6_DO_0_18;
	wire	[31:0]	VECTOR_6_DO_0_19;
	wire	[31:0]	VECTOR_6_DO_0_20;
	wire	[31:0]	VECTOR_6_DO_0_21;
	wire	[31:0]	VECTOR_6_DO_0_22;
	wire	[31:0]	VECTOR_6_DO_0_23;
	wire	[31:0]	VECTOR_6_DO_0_24;
	wire	[31:0]	VECTOR_6_DO_0_25;
	wire	[31:0]	VECTOR_6_DO_0_26;
	wire	[31:0]	VECTOR_6_DO_0_27;
	wire	[31:0]	VECTOR_6_DO_0_28;
	wire	[31:0]	VECTOR_6_DO_0_29;
	wire	[31:0]	VECTOR_6_DO_0_30;
	wire	[31:0]	VECTOR_6_DO_0_31;
	wire	[31:0]	VECTOR_6_DO_0_32;
	wire	[31:0]	VECTOR_6_DO_0_33;
	wire	[31:0]	VECTOR_6_DO_0_34;
	wire	[31:0]	VECTOR_6_DO_0_35;
	wire	[31:0]	VECTOR_6_DO_0_36;
	wire	[31:0]	VECTOR_6_DO_0_37;
	wire	[31:0]	VECTOR_6_DO_0_38;
	wire	[31:0]	VECTOR_6_DO_0_39;
	wire	[31:0]	VECTOR_6_DO_0_40;
	wire	[31:0]	VECTOR_6_DO_0_41;
	wire	[31:0]	VECTOR_6_DO_0_42;
	wire	[31:0]	VECTOR_6_DO_0_43;
	wire	[31:0]	VECTOR_6_DO_0_44;
	wire	[31:0]	VECTOR_6_DO_0_45;
	wire	[31:0]	VECTOR_6_DO_0_46;
	wire	[31:0]	VECTOR_6_DO_0_47;
	wire	[31:0]	VECTOR_6_DO_0_48;
	wire	[31:0]	VECTOR_6_DO_0_49;
	wire	[31:0]	VECTOR_6_DO_0_50;
	wire	[31:0]	VECTOR_6_DO_0_51;
	wire	[31:0]	VECTOR_6_DO_0_52;
	wire	[31:0]	VECTOR_6_DO_0_53;
	wire	[31:0]	VECTOR_6_DO_0_54;
	wire	[31:0]	VECTOR_6_DO_0_55;
	wire	[31:0]	VECTOR_6_DO_0_56;
	wire	[31:0]	VECTOR_6_DO_0_57;
	wire	[31:0]	VECTOR_6_DO_0_58;
	wire	[31:0]	VECTOR_6_DO_0_59;
	wire	[31:0]	VECTOR_6_DO_0_60;
	wire	[31:0]	VECTOR_6_DO_0_61;
	wire	[31:0]	VECTOR_6_DO_0_62;
	wire	[31:0]	VECTOR_6_DO_0_63;

	wire	[31:0]	VECTOR_6_DO_SUM;

	wire		VECTOR_6_EN_DI_0_0;
	wire		VECTOR_6_EN_DI_0_1;
	wire		VECTOR_6_EN_DI_1_0;
	wire		VECTOR_6_EN_DI_1_1;
	wire		VECTOR_6_EN_DO_0_0;
	wire		VECTOR_6_EN_DO_0_1;

	wire		VECTOR_6_SEL_DI_0_R;
	wire		VECTOR_6_SEL_DI_1_R;
	wire		VECTOR_6_SEL_DO_0_R;
	wire		VECTOR_6_SEL_DO_0_W;
	wire		VECTOR_6_SEL_DO_SUM_PREC;

	wire	[1:0]	VECTOR_6_SEL_OP;
	wire		VECTOR_6_SEL_PREC;
	wire	[2:0]	VECTOR_6_SEL_BLOCK_LOAD;
	
	wire		VECTOR_6_VECTOR_EN;
	wire		VECTOR_6_VECTOR_LOAD_EN;
	wire	[1:0]	VECTOR_6_VECTOR_MODE;

	
	VECTOR vector_6 (
		.DI_0_00(VECTOR_6_DI_0_00),	
		.DI_0_01(VECTOR_6_DI_0_01),	
		.DI_0_02(VECTOR_6_DI_0_02),	
		.DI_0_03(VECTOR_6_DI_0_03),	
		.DI_0_04(VECTOR_6_DI_0_04),	
		.DI_0_05(VECTOR_6_DI_0_05),	
		.DI_0_06(VECTOR_6_DI_0_06),	
		.DI_0_07(VECTOR_6_DI_0_07),	
		.DI_0_08(VECTOR_6_DI_0_08),	
		.DI_0_09(VECTOR_6_DI_0_09),	
		.DI_0_10(VECTOR_6_DI_0_10),	
		.DI_0_11(VECTOR_6_DI_0_11),	
		.DI_0_12(VECTOR_6_DI_0_12),	
		.DI_0_13(VECTOR_6_DI_0_13),	
		.DI_0_14(VECTOR_6_DI_0_14),	
		.DI_0_15(VECTOR_6_DI_0_15),	
		.DI_0_16(VECTOR_6_DI_0_16),	
		.DI_0_17(VECTOR_6_DI_0_17),	
		.DI_0_18(VECTOR_6_DI_0_18),	
		.DI_0_19(VECTOR_6_DI_0_19),	
		.DI_0_20(VECTOR_6_DI_0_20),	
		.DI_0_21(VECTOR_6_DI_0_21),	
		.DI_0_22(VECTOR_6_DI_0_22),	
		.DI_0_23(VECTOR_6_DI_0_23),	
		.DI_0_24(VECTOR_6_DI_0_24),	
		.DI_0_25(VECTOR_6_DI_0_25),	
		.DI_0_26(VECTOR_6_DI_0_26),	
		.DI_0_27(VECTOR_6_DI_0_27),	
		.DI_0_28(VECTOR_6_DI_0_28),	
		.DI_0_29(VECTOR_6_DI_0_29),	
		.DI_0_30(VECTOR_6_DI_0_30),	
		.DI_0_31(VECTOR_6_DI_0_31),	
		.DI_0_32(VECTOR_6_DI_0_32),	
		.DI_0_33(VECTOR_6_DI_0_33),	
		.DI_0_34(VECTOR_6_DI_0_34),	
		.DI_0_35(VECTOR_6_DI_0_35),	
		.DI_0_36(VECTOR_6_DI_0_36),	
		.DI_0_37(VECTOR_6_DI_0_37),	
		.DI_0_38(VECTOR_6_DI_0_38),	
		.DI_0_39(VECTOR_6_DI_0_39),	
		.DI_0_40(VECTOR_6_DI_0_40),	
		.DI_0_41(VECTOR_6_DI_0_41),	
		.DI_0_42(VECTOR_6_DI_0_42),	
		.DI_0_43(VECTOR_6_DI_0_43),	
		.DI_0_44(VECTOR_6_DI_0_44),	
		.DI_0_45(VECTOR_6_DI_0_45),	
		.DI_0_46(VECTOR_6_DI_0_46),	
		.DI_0_47(VECTOR_6_DI_0_47),	
		.DI_0_48(VECTOR_6_DI_0_48),	
		.DI_0_49(VECTOR_6_DI_0_49),	
		.DI_0_50(VECTOR_6_DI_0_50),	
		.DI_0_51(VECTOR_6_DI_0_51),	
		.DI_0_52(VECTOR_6_DI_0_52),	
		.DI_0_53(VECTOR_6_DI_0_53),	
		.DI_0_54(VECTOR_6_DI_0_54),	
		.DI_0_55(VECTOR_6_DI_0_55),	
		.DI_0_56(VECTOR_6_DI_0_56),	
		.DI_0_57(VECTOR_6_DI_0_57),	
		.DI_0_58(VECTOR_6_DI_0_58),	
		.DI_0_59(VECTOR_6_DI_0_59),	
		.DI_0_60(VECTOR_6_DI_0_60),	
		.DI_0_61(VECTOR_6_DI_0_61),	
		.DI_0_62(VECTOR_6_DI_0_62),	
		.DI_0_63(VECTOR_6_DI_0_63),	
		
		.DO_0_00(VECTOR_6_DO_0_00),	
		.DO_0_01(VECTOR_6_DO_0_01),	
		.DO_0_02(VECTOR_6_DO_0_02),	
		.DO_0_03(VECTOR_6_DO_0_03),	
		.DO_0_04(VECTOR_6_DO_0_04),	
		.DO_0_05(VECTOR_6_DO_0_05),	
		.DO_0_06(VECTOR_6_DO_0_06),	
		.DO_0_07(VECTOR_6_DO_0_07),	
		.DO_0_08(VECTOR_6_DO_0_08),	
		.DO_0_09(VECTOR_6_DO_0_09),	
		.DO_0_10(VECTOR_6_DO_0_10),	
		.DO_0_11(VECTOR_6_DO_0_11),	
		.DO_0_12(VECTOR_6_DO_0_12),	
		.DO_0_13(VECTOR_6_DO_0_13),	
		.DO_0_14(VECTOR_6_DO_0_14),	
		.DO_0_15(VECTOR_6_DO_0_15),	
		.DO_0_16(VECTOR_6_DO_0_16),	
		.DO_0_17(VECTOR_6_DO_0_17),	
		.DO_0_18(VECTOR_6_DO_0_18),	
		.DO_0_19(VECTOR_6_DO_0_19),	
		.DO_0_20(VECTOR_6_DO_0_20),	
		.DO_0_21(VECTOR_6_DO_0_21),	
		.DO_0_22(VECTOR_6_DO_0_22),	
		.DO_0_23(VECTOR_6_DO_0_23),	
		.DO_0_24(VECTOR_6_DO_0_24),	
		.DO_0_25(VECTOR_6_DO_0_25),	
		.DO_0_26(VECTOR_6_DO_0_26),	
		.DO_0_27(VECTOR_6_DO_0_27),	
		.DO_0_28(VECTOR_6_DO_0_28),	
		.DO_0_29(VECTOR_6_DO_0_29),	
		.DO_0_30(VECTOR_6_DO_0_30),	
		.DO_0_31(VECTOR_6_DO_0_31),	
		.DO_0_32(VECTOR_6_DO_0_32),	
		.DO_0_33(VECTOR_6_DO_0_33),	
		.DO_0_34(VECTOR_6_DO_0_34),	
		.DO_0_35(VECTOR_6_DO_0_35),	
		.DO_0_36(VECTOR_6_DO_0_36),	
		.DO_0_37(VECTOR_6_DO_0_37),	
		.DO_0_38(VECTOR_6_DO_0_38),	
		.DO_0_39(VECTOR_6_DO_0_39),	
		.DO_0_40(VECTOR_6_DO_0_40),	
		.DO_0_41(VECTOR_6_DO_0_41),	
		.DO_0_42(VECTOR_6_DO_0_42),	
		.DO_0_43(VECTOR_6_DO_0_43),	
		.DO_0_44(VECTOR_6_DO_0_44),	
		.DO_0_45(VECTOR_6_DO_0_45),	
		.DO_0_46(VECTOR_6_DO_0_46),	
		.DO_0_47(VECTOR_6_DO_0_47),	
		.DO_0_48(VECTOR_6_DO_0_48),	
		.DO_0_49(VECTOR_6_DO_0_49),	
		.DO_0_50(VECTOR_6_DO_0_50),	
		.DO_0_51(VECTOR_6_DO_0_51),	
		.DO_0_52(VECTOR_6_DO_0_52),	
		.DO_0_53(VECTOR_6_DO_0_53),	
		.DO_0_54(VECTOR_6_DO_0_54),	
		.DO_0_55(VECTOR_6_DO_0_55),	
		.DO_0_56(VECTOR_6_DO_0_56),	
		.DO_0_57(VECTOR_6_DO_0_57),	
		.DO_0_58(VECTOR_6_DO_0_58),	
		.DO_0_59(VECTOR_6_DO_0_59),	
		.DO_0_60(VECTOR_6_DO_0_60),	
		.DO_0_61(VECTOR_6_DO_0_61),	
		.DO_0_62(VECTOR_6_DO_0_62),	
		.DO_0_63(VECTOR_6_DO_0_63),

		.DO_SUM(VECTOR_6_DO_SUM),

		.EN_DI_0_0(VECTOR_6_EN_DI_0_0),
		.EN_DI_0_1(VECTOR_6_EN_DI_0_1),
		.EN_DI_1_0(VECTOR_6_EN_DI_1_0),
		.EN_DI_1_1(VECTOR_6_EN_DI_1_1),
		.EN_DO_0_0(VECTOR_6_EN_DO_0_0),
		.EN_DO_0_1(VECTOR_6_EN_DO_0_1),

		.SEL_DI_0_R(VECTOR_6_SEL_DI_0_R),
		.SEL_DI_1_R(VECTOR_6_SEL_DI_1_R),
		.SEL_DO_0_R(VECTOR_6_SEL_DO_0_R),
		.SEL_DO_0_W(VECTOR_6_SEL_DO_0_W),
		.SEL_DO_SUM_PREC(VECTOR_6_SEL_DO_SUM_PREC),

		.SEL_OP(VECTOR_6_SEL_OP),
		.SEL_PREC(VECTOR_6_SEL_PREC),
		.SEL_BLOCK_LOAD(VECTOR_6_SEL_BLOCK_LOAD),

		.VECTOR_EN(VECTOR_6_VECTOR_EN),
		.VECTOR_LOAD_EN(VECTOR_6_VECTOR_LOAD_EN),
		.VECTOR_MODE(VECTOR_6_VECTOR_MODE),

		.CLK(CLK),
		.RSTn(RSTn)
	);


	wire	[31:0]	VECTOR_7_DI_0_00;
	wire	[31:0]	VECTOR_7_DI_0_01;
	wire	[31:0]	VECTOR_7_DI_0_02;
	wire	[31:0]	VECTOR_7_DI_0_03;
	wire	[31:0]	VECTOR_7_DI_0_04;
	wire	[31:0]	VECTOR_7_DI_0_05;
	wire	[31:0]	VECTOR_7_DI_0_06;
	wire	[31:0]	VECTOR_7_DI_0_07;
	wire	[31:0]	VECTOR_7_DI_0_08;
	wire	[31:0]	VECTOR_7_DI_0_09;
	wire	[31:0]	VECTOR_7_DI_0_10;
	wire	[31:0]	VECTOR_7_DI_0_11;
	wire	[31:0]	VECTOR_7_DI_0_12;
	wire	[31:0]	VECTOR_7_DI_0_13;
	wire	[31:0]	VECTOR_7_DI_0_14;
	wire	[31:0]	VECTOR_7_DI_0_15;
	wire	[31:0]	VECTOR_7_DI_0_16;
	wire	[31:0]	VECTOR_7_DI_0_17;
	wire	[31:0]	VECTOR_7_DI_0_18;
	wire	[31:0]	VECTOR_7_DI_0_19;
	wire	[31:0]	VECTOR_7_DI_0_20;
	wire	[31:0]	VECTOR_7_DI_0_21;
	wire	[31:0]	VECTOR_7_DI_0_22;
	wire	[31:0]	VECTOR_7_DI_0_23;
	wire	[31:0]	VECTOR_7_DI_0_24;
	wire	[31:0]	VECTOR_7_DI_0_25;
	wire	[31:0]	VECTOR_7_DI_0_26;
	wire	[31:0]	VECTOR_7_DI_0_27;
	wire	[31:0]	VECTOR_7_DI_0_28;
	wire	[31:0]	VECTOR_7_DI_0_29;
	wire	[31:0]	VECTOR_7_DI_0_30;
	wire	[31:0]	VECTOR_7_DI_0_31;
	wire	[31:0]	VECTOR_7_DI_0_32;
	wire	[31:0]	VECTOR_7_DI_0_33;
	wire	[31:0]	VECTOR_7_DI_0_34;
	wire	[31:0]	VECTOR_7_DI_0_35;
	wire	[31:0]	VECTOR_7_DI_0_36;
	wire	[31:0]	VECTOR_7_DI_0_37;
	wire	[31:0]	VECTOR_7_DI_0_38;
	wire	[31:0]	VECTOR_7_DI_0_39;
	wire	[31:0]	VECTOR_7_DI_0_40;
	wire	[31:0]	VECTOR_7_DI_0_41;
	wire	[31:0]	VECTOR_7_DI_0_42;
	wire	[31:0]	VECTOR_7_DI_0_43;
	wire	[31:0]	VECTOR_7_DI_0_44;
	wire	[31:0]	VECTOR_7_DI_0_45;
	wire	[31:0]	VECTOR_7_DI_0_46;
	wire	[31:0]	VECTOR_7_DI_0_47;
	wire	[31:0]	VECTOR_7_DI_0_48;
	wire	[31:0]	VECTOR_7_DI_0_49;
	wire	[31:0]	VECTOR_7_DI_0_50;
	wire	[31:0]	VECTOR_7_DI_0_51;
	wire	[31:0]	VECTOR_7_DI_0_52;
	wire	[31:0]	VECTOR_7_DI_0_53;
	wire	[31:0]	VECTOR_7_DI_0_54;
	wire	[31:0]	VECTOR_7_DI_0_55;
	wire	[31:0]	VECTOR_7_DI_0_56;
	wire	[31:0]	VECTOR_7_DI_0_57;
	wire	[31:0]	VECTOR_7_DI_0_58;
	wire	[31:0]	VECTOR_7_DI_0_59;
	wire	[31:0]	VECTOR_7_DI_0_60;
	wire	[31:0]	VECTOR_7_DI_0_61;
	wire	[31:0]	VECTOR_7_DI_0_62;
	wire	[31:0]	VECTOR_7_DI_0_63;
	
	wire	[31:0]	VECTOR_7_DO_0_00;
	wire	[31:0]	VECTOR_7_DO_0_01;
	wire	[31:0]	VECTOR_7_DO_0_02;
	wire	[31:0]	VECTOR_7_DO_0_03;
	wire	[31:0]	VECTOR_7_DO_0_04;
	wire	[31:0]	VECTOR_7_DO_0_05;
	wire	[31:0]	VECTOR_7_DO_0_06;
	wire	[31:0]	VECTOR_7_DO_0_07;
	wire	[31:0]	VECTOR_7_DO_0_08;
	wire	[31:0]	VECTOR_7_DO_0_09;
	wire	[31:0]	VECTOR_7_DO_0_10;
	wire	[31:0]	VECTOR_7_DO_0_11;
	wire	[31:0]	VECTOR_7_DO_0_12;
	wire	[31:0]	VECTOR_7_DO_0_13;
	wire	[31:0]	VECTOR_7_DO_0_14;
	wire	[31:0]	VECTOR_7_DO_0_15;
	wire	[31:0]	VECTOR_7_DO_0_16;
	wire	[31:0]	VECTOR_7_DO_0_17;
	wire	[31:0]	VECTOR_7_DO_0_18;
	wire	[31:0]	VECTOR_7_DO_0_19;
	wire	[31:0]	VECTOR_7_DO_0_20;
	wire	[31:0]	VECTOR_7_DO_0_21;
	wire	[31:0]	VECTOR_7_DO_0_22;
	wire	[31:0]	VECTOR_7_DO_0_23;
	wire	[31:0]	VECTOR_7_DO_0_24;
	wire	[31:0]	VECTOR_7_DO_0_25;
	wire	[31:0]	VECTOR_7_DO_0_26;
	wire	[31:0]	VECTOR_7_DO_0_27;
	wire	[31:0]	VECTOR_7_DO_0_28;
	wire	[31:0]	VECTOR_7_DO_0_29;
	wire	[31:0]	VECTOR_7_DO_0_30;
	wire	[31:0]	VECTOR_7_DO_0_31;
	wire	[31:0]	VECTOR_7_DO_0_32;
	wire	[31:0]	VECTOR_7_DO_0_33;
	wire	[31:0]	VECTOR_7_DO_0_34;
	wire	[31:0]	VECTOR_7_DO_0_35;
	wire	[31:0]	VECTOR_7_DO_0_36;
	wire	[31:0]	VECTOR_7_DO_0_37;
	wire	[31:0]	VECTOR_7_DO_0_38;
	wire	[31:0]	VECTOR_7_DO_0_39;
	wire	[31:0]	VECTOR_7_DO_0_40;
	wire	[31:0]	VECTOR_7_DO_0_41;
	wire	[31:0]	VECTOR_7_DO_0_42;
	wire	[31:0]	VECTOR_7_DO_0_43;
	wire	[31:0]	VECTOR_7_DO_0_44;
	wire	[31:0]	VECTOR_7_DO_0_45;
	wire	[31:0]	VECTOR_7_DO_0_46;
	wire	[31:0]	VECTOR_7_DO_0_47;
	wire	[31:0]	VECTOR_7_DO_0_48;
	wire	[31:0]	VECTOR_7_DO_0_49;
	wire	[31:0]	VECTOR_7_DO_0_50;
	wire	[31:0]	VECTOR_7_DO_0_51;
	wire	[31:0]	VECTOR_7_DO_0_52;
	wire	[31:0]	VECTOR_7_DO_0_53;
	wire	[31:0]	VECTOR_7_DO_0_54;
	wire	[31:0]	VECTOR_7_DO_0_55;
	wire	[31:0]	VECTOR_7_DO_0_56;
	wire	[31:0]	VECTOR_7_DO_0_57;
	wire	[31:0]	VECTOR_7_DO_0_58;
	wire	[31:0]	VECTOR_7_DO_0_59;
	wire	[31:0]	VECTOR_7_DO_0_60;
	wire	[31:0]	VECTOR_7_DO_0_61;
	wire	[31:0]	VECTOR_7_DO_0_62;
	wire	[31:0]	VECTOR_7_DO_0_63;

	wire	[31:0]	VECTOR_7_DO_SUM;

	wire		VECTOR_7_EN_DI_0_0;
	wire		VECTOR_7_EN_DI_0_1;
	wire		VECTOR_7_EN_DI_1_0;
	wire		VECTOR_7_EN_DI_1_1;
	wire		VECTOR_7_EN_DO_0_0;
	wire		VECTOR_7_EN_DO_0_1;

	wire		VECTOR_7_SEL_DI_0_R;
	wire		VECTOR_7_SEL_DI_1_R;
	wire		VECTOR_7_SEL_DO_0_R;
	wire		VECTOR_7_SEL_DO_0_W;
	wire		VECTOR_7_SEL_DO_SUM_PREC;

	wire	[1:0]	VECTOR_7_SEL_OP;
	wire		VECTOR_7_SEL_PREC;
	wire	[2:0]	VECTOR_7_SEL_BLOCK_LOAD;

	wire		VECTOR_7_VECTOR_EN;
	wire		VECTOR_7_VECTOR_LOAD_EN;
	wire	[1:0]	VECTOR_7_VECTOR_MODE;
	
	
	VECTOR vector_7 (
		.DI_0_00(VECTOR_7_DI_0_00),	
		.DI_0_01(VECTOR_7_DI_0_01),	
		.DI_0_02(VECTOR_7_DI_0_02),	
		.DI_0_03(VECTOR_7_DI_0_03),	
		.DI_0_04(VECTOR_7_DI_0_04),	
		.DI_0_05(VECTOR_7_DI_0_05),	
		.DI_0_06(VECTOR_7_DI_0_06),	
		.DI_0_07(VECTOR_7_DI_0_07),	
		.DI_0_08(VECTOR_7_DI_0_08),	
		.DI_0_09(VECTOR_7_DI_0_09),	
		.DI_0_10(VECTOR_7_DI_0_10),	
		.DI_0_11(VECTOR_7_DI_0_11),	
		.DI_0_12(VECTOR_7_DI_0_12),	
		.DI_0_13(VECTOR_7_DI_0_13),	
		.DI_0_14(VECTOR_7_DI_0_14),	
		.DI_0_15(VECTOR_7_DI_0_15),	
		.DI_0_16(VECTOR_7_DI_0_16),	
		.DI_0_17(VECTOR_7_DI_0_17),	
		.DI_0_18(VECTOR_7_DI_0_18),	
		.DI_0_19(VECTOR_7_DI_0_19),	
		.DI_0_20(VECTOR_7_DI_0_20),	
		.DI_0_21(VECTOR_7_DI_0_21),	
		.DI_0_22(VECTOR_7_DI_0_22),	
		.DI_0_23(VECTOR_7_DI_0_23),	
		.DI_0_24(VECTOR_7_DI_0_24),	
		.DI_0_25(VECTOR_7_DI_0_25),	
		.DI_0_26(VECTOR_7_DI_0_26),	
		.DI_0_27(VECTOR_7_DI_0_27),	
		.DI_0_28(VECTOR_7_DI_0_28),	
		.DI_0_29(VECTOR_7_DI_0_29),	
		.DI_0_30(VECTOR_7_DI_0_30),	
		.DI_0_31(VECTOR_7_DI_0_31),	
		.DI_0_32(VECTOR_7_DI_0_32),	
		.DI_0_33(VECTOR_7_DI_0_33),	
		.DI_0_34(VECTOR_7_DI_0_34),	
		.DI_0_35(VECTOR_7_DI_0_35),	
		.DI_0_36(VECTOR_7_DI_0_36),	
		.DI_0_37(VECTOR_7_DI_0_37),	
		.DI_0_38(VECTOR_7_DI_0_38),	
		.DI_0_39(VECTOR_7_DI_0_39),	
		.DI_0_40(VECTOR_7_DI_0_40),	
		.DI_0_41(VECTOR_7_DI_0_41),	
		.DI_0_42(VECTOR_7_DI_0_42),	
		.DI_0_43(VECTOR_7_DI_0_43),	
		.DI_0_44(VECTOR_7_DI_0_44),	
		.DI_0_45(VECTOR_7_DI_0_45),	
		.DI_0_46(VECTOR_7_DI_0_46),	
		.DI_0_47(VECTOR_7_DI_0_47),	
		.DI_0_48(VECTOR_7_DI_0_48),	
		.DI_0_49(VECTOR_7_DI_0_49),	
		.DI_0_50(VECTOR_7_DI_0_50),	
		.DI_0_51(VECTOR_7_DI_0_51),	
		.DI_0_52(VECTOR_7_DI_0_52),	
		.DI_0_53(VECTOR_7_DI_0_53),	
		.DI_0_54(VECTOR_7_DI_0_54),	
		.DI_0_55(VECTOR_7_DI_0_55),	
		.DI_0_56(VECTOR_7_DI_0_56),	
		.DI_0_57(VECTOR_7_DI_0_57),	
		.DI_0_58(VECTOR_7_DI_0_58),	
		.DI_0_59(VECTOR_7_DI_0_59),	
		.DI_0_60(VECTOR_7_DI_0_60),	
		.DI_0_61(VECTOR_7_DI_0_61),	
		.DI_0_62(VECTOR_7_DI_0_62),	
		.DI_0_63(VECTOR_7_DI_0_63),	
		
		.DO_0_00(VECTOR_7_DO_0_00),	
		.DO_0_01(VECTOR_7_DO_0_01),	
		.DO_0_02(VECTOR_7_DO_0_02),	
		.DO_0_03(VECTOR_7_DO_0_03),	
		.DO_0_04(VECTOR_7_DO_0_04),	
		.DO_0_05(VECTOR_7_DO_0_05),	
		.DO_0_06(VECTOR_7_DO_0_06),	
		.DO_0_07(VECTOR_7_DO_0_07),	
		.DO_0_08(VECTOR_7_DO_0_08),	
		.DO_0_09(VECTOR_7_DO_0_09),	
		.DO_0_10(VECTOR_7_DO_0_10),	
		.DO_0_11(VECTOR_7_DO_0_11),	
		.DO_0_12(VECTOR_7_DO_0_12),	
		.DO_0_13(VECTOR_7_DO_0_13),	
		.DO_0_14(VECTOR_7_DO_0_14),	
		.DO_0_15(VECTOR_7_DO_0_15),	
		.DO_0_16(VECTOR_7_DO_0_16),	
		.DO_0_17(VECTOR_7_DO_0_17),	
		.DO_0_18(VECTOR_7_DO_0_18),	
		.DO_0_19(VECTOR_7_DO_0_19),	
		.DO_0_20(VECTOR_7_DO_0_20),	
		.DO_0_21(VECTOR_7_DO_0_21),	
		.DO_0_22(VECTOR_7_DO_0_22),	
		.DO_0_23(VECTOR_7_DO_0_23),	
		.DO_0_24(VECTOR_7_DO_0_24),	
		.DO_0_25(VECTOR_7_DO_0_25),	
		.DO_0_26(VECTOR_7_DO_0_26),	
		.DO_0_27(VECTOR_7_DO_0_27),	
		.DO_0_28(VECTOR_7_DO_0_28),	
		.DO_0_29(VECTOR_7_DO_0_29),	
		.DO_0_30(VECTOR_7_DO_0_30),	
		.DO_0_31(VECTOR_7_DO_0_31),	
		.DO_0_32(VECTOR_7_DO_0_32),	
		.DO_0_33(VECTOR_7_DO_0_33),	
		.DO_0_34(VECTOR_7_DO_0_34),	
		.DO_0_35(VECTOR_7_DO_0_35),	
		.DO_0_36(VECTOR_7_DO_0_36),	
		.DO_0_37(VECTOR_7_DO_0_37),	
		.DO_0_38(VECTOR_7_DO_0_38),	
		.DO_0_39(VECTOR_7_DO_0_39),	
		.DO_0_40(VECTOR_7_DO_0_40),	
		.DO_0_41(VECTOR_7_DO_0_41),	
		.DO_0_42(VECTOR_7_DO_0_42),	
		.DO_0_43(VECTOR_7_DO_0_43),	
		.DO_0_44(VECTOR_7_DO_0_44),	
		.DO_0_45(VECTOR_7_DO_0_45),	
		.DO_0_46(VECTOR_7_DO_0_46),	
		.DO_0_47(VECTOR_7_DO_0_47),	
		.DO_0_48(VECTOR_7_DO_0_48),	
		.DO_0_49(VECTOR_7_DO_0_49),	
		.DO_0_50(VECTOR_7_DO_0_50),	
		.DO_0_51(VECTOR_7_DO_0_51),	
		.DO_0_52(VECTOR_7_DO_0_52),	
		.DO_0_53(VECTOR_7_DO_0_53),	
		.DO_0_54(VECTOR_7_DO_0_54),	
		.DO_0_55(VECTOR_7_DO_0_55),	
		.DO_0_56(VECTOR_7_DO_0_56),	
		.DO_0_57(VECTOR_7_DO_0_57),	
		.DO_0_58(VECTOR_7_DO_0_58),	
		.DO_0_59(VECTOR_7_DO_0_59),	
		.DO_0_60(VECTOR_7_DO_0_60),	
		.DO_0_61(VECTOR_7_DO_0_61),	
		.DO_0_62(VECTOR_7_DO_0_62),	
		.DO_0_63(VECTOR_7_DO_0_63),

		.DO_SUM(VECTOR_7_DO_SUM),

		.EN_DI_0_0(VECTOR_7_EN_DI_0_0),
		.EN_DI_0_1(VECTOR_7_EN_DI_0_1),
		.EN_DI_1_0(VECTOR_7_EN_DI_1_0),
		.EN_DI_1_1(VECTOR_7_EN_DI_1_1),
		.EN_DO_0_0(VECTOR_7_EN_DO_0_0),
		.EN_DO_0_1(VECTOR_7_EN_DO_0_1),

		.SEL_DI_0_R(VECTOR_7_SEL_DI_0_R),
		.SEL_DI_1_R(VECTOR_7_SEL_DI_1_R),
		.SEL_DO_0_R(VECTOR_7_SEL_DO_0_R),
		.SEL_DO_0_W(VECTOR_7_SEL_DO_0_W),
		.SEL_DO_SUM_PREC(VECTOR_7_SEL_DO_SUM_PREC),

		.SEL_OP(VECTOR_7_SEL_OP),
		.SEL_PREC(VECTOR_7_SEL_PREC),
		.SEL_BLOCK_LOAD(VECTOR_7_SEL_BLOCK_LOAD),

		.VECTOR_EN(VECTOR_7_VECTOR_EN),
		.VECTOR_LOAD_EN(VECTOR_7_VECTOR_LOAD_EN),
		.VECTOR_MODE(VECTOR_7_VECTOR_MODE),

		.CLK(CLK),
		.RSTn(RSTn)
	);

	assign	VECTOR_0_EN_DI_0_0	=	CORE_VECTOR_LOAD_EN[0] & CORE_VECTOR_EN_DI_0_0;
	assign	VECTOR_0_EN_DI_0_1	=	CORE_VECTOR_LOAD_EN[0] & CORE_VECTOR_EN_DI_0_1;
	assign	VECTOR_0_EN_DI_1_0	=	CORE_VECTOR_LOAD_EN[0] & CORE_VECTOR_EN_DI_1_0;
	assign	VECTOR_0_EN_DI_1_1	=	CORE_VECTOR_LOAD_EN[0] & CORE_VECTOR_EN_DI_1_1;
	assign	VECTOR_0_EN_DO_0_0	=	CORE_VECTOR_EN[0] & CORE_VECTOR_EN_DO_0_0;
	assign	VECTOR_0_EN_DO_0_1	=	CORE_VECTOR_EN[0] & CORE_VECTOR_EN_DO_0_1;

	assign	VECTOR_0_SEL_DI_0_R	=	CORE_VECTOR_SEL_DI_0_R;
	assign	VECTOR_0_SEL_DI_1_R	=	CORE_VECTOR_SEL_DI_1_R;
	assign	VECTOR_0_SEL_DO_0_R	=	CORE_VECTOR_SEL_DO_0_R;
	assign	VECTOR_0_SEL_DO_0_W	=	CORE_VECTOR_SEL_DO_0_W;
	assign	VECTOR_0_SEL_DO_SUM_PREC	=	CORE_MEMSET_SEL_PREC;

	assign	VECTOR_0_SEL_OP		=	CORE_VECTOR_SEL_OP;
	assign	VECTOR_0_SEL_PREC	=	CORE_VECTOR_SEL_PREC;

	assign	VECTOR_0_VECTOR_EN	=	CORE_VECTOR_EN[0];
	assign	VECTOR_0_VECTOR_LOAD_EN	=	CORE_VECTOR_LOAD_EN[0];
	assign	VECTOR_0_VECTOR_MODE	=	CORE_VECTOR_MODE;


	assign	VECTOR_1_EN_DI_0_0	=	CORE_VECTOR_LOAD_EN[1] & CORE_VECTOR_EN_DI_0_0;
	assign	VECTOR_1_EN_DI_0_1	=	CORE_VECTOR_LOAD_EN[1] & CORE_VECTOR_EN_DI_0_1;
	assign	VECTOR_1_EN_DI_1_0	=	CORE_VECTOR_LOAD_EN[1] & CORE_VECTOR_EN_DI_1_0;
	assign	VECTOR_1_EN_DI_1_1	=	CORE_VECTOR_LOAD_EN[1] & CORE_VECTOR_EN_DI_1_1;
	assign	VECTOR_1_EN_DO_0_0	=	CORE_VECTOR_EN[1] & CORE_VECTOR_EN_DO_0_0;
	assign	VECTOR_1_EN_DO_0_1	=	CORE_VECTOR_EN[1] & CORE_VECTOR_EN_DO_0_1;

	assign	VECTOR_1_SEL_DI_0_R	=	CORE_VECTOR_SEL_DI_0_R;
	assign	VECTOR_1_SEL_DI_1_R	=	CORE_VECTOR_SEL_DI_1_R;
	assign	VECTOR_1_SEL_DO_0_R	=	CORE_VECTOR_SEL_DO_0_R;
	assign	VECTOR_1_SEL_DO_0_W	=	CORE_VECTOR_SEL_DO_0_W;
	assign	VECTOR_1_SEL_DO_SUM_PREC	=	CORE_MEMSET_SEL_PREC;

	assign	VECTOR_1_SEL_OP		=	CORE_VECTOR_SEL_OP;
	assign	VECTOR_1_SEL_PREC	=	CORE_VECTOR_SEL_PREC;

	assign	VECTOR_1_VECTOR_EN	=	CORE_VECTOR_EN[1];
	assign	VECTOR_1_VECTOR_LOAD_EN	=	CORE_VECTOR_LOAD_EN[1];
	assign	VECTOR_1_VECTOR_MODE	=	CORE_VECTOR_MODE;


	assign	VECTOR_2_EN_DI_0_0	=	CORE_VECTOR_LOAD_EN[2] & CORE_VECTOR_EN_DI_0_0;
	assign	VECTOR_2_EN_DI_0_1	=	CORE_VECTOR_LOAD_EN[2] & CORE_VECTOR_EN_DI_0_1;
	assign	VECTOR_2_EN_DI_1_0	=	CORE_VECTOR_LOAD_EN[2] & CORE_VECTOR_EN_DI_1_0;
	assign	VECTOR_2_EN_DI_1_1	=	CORE_VECTOR_LOAD_EN[2] & CORE_VECTOR_EN_DI_1_1;
	assign	VECTOR_2_EN_DO_0_0	=	CORE_VECTOR_EN[2] & CORE_VECTOR_EN_DO_0_0;
	assign	VECTOR_2_EN_DO_0_1	=	CORE_VECTOR_EN[2] & CORE_VECTOR_EN_DO_0_1;

	assign	VECTOR_2_SEL_DI_0_R	=	CORE_VECTOR_SEL_DI_0_R;
	assign	VECTOR_2_SEL_DI_1_R	=	CORE_VECTOR_SEL_DI_1_R;
	assign	VECTOR_2_SEL_DO_0_R	=	CORE_VECTOR_SEL_DO_0_R;
	assign	VECTOR_2_SEL_DO_0_W	=	CORE_VECTOR_SEL_DO_0_W;
	assign	VECTOR_2_SEL_DO_SUM_PREC	=	CORE_MEMSET_SEL_PREC;

	assign	VECTOR_2_SEL_OP		=	CORE_VECTOR_SEL_OP;
	assign	VECTOR_2_SEL_PREC	=	CORE_VECTOR_SEL_PREC;

	assign	VECTOR_2_VECTOR_EN	=	CORE_VECTOR_EN[2];
	assign	VECTOR_2_VECTOR_LOAD_EN	=	CORE_VECTOR_LOAD_EN[2];
	assign	VECTOR_2_VECTOR_MODE	=	CORE_VECTOR_MODE;


	assign	VECTOR_3_EN_DI_0_0	=	CORE_VECTOR_LOAD_EN[3] & CORE_VECTOR_EN_DI_0_0;
	assign	VECTOR_3_EN_DI_0_1	=	CORE_VECTOR_LOAD_EN[3] & CORE_VECTOR_EN_DI_0_1;
	assign	VECTOR_3_EN_DI_1_0	=	CORE_VECTOR_LOAD_EN[3] & CORE_VECTOR_EN_DI_1_0;
	assign	VECTOR_3_EN_DI_1_1	=	CORE_VECTOR_LOAD_EN[3] & CORE_VECTOR_EN_DI_1_1;
	assign	VECTOR_3_EN_DO_0_0	=	CORE_VECTOR_EN[3] & CORE_VECTOR_EN_DO_0_0;
	assign	VECTOR_3_EN_DO_0_1	=	CORE_VECTOR_EN[3] & CORE_VECTOR_EN_DO_0_1;

	assign	VECTOR_3_SEL_DI_0_R	=	CORE_VECTOR_SEL_DI_0_R;
	assign	VECTOR_3_SEL_DI_1_R	=	CORE_VECTOR_SEL_DI_1_R;
	assign	VECTOR_3_SEL_DO_0_R	=	CORE_VECTOR_SEL_DO_0_R;
	assign	VECTOR_3_SEL_DO_0_W	=	CORE_VECTOR_SEL_DO_0_W;
	assign	VECTOR_3_SEL_DO_SUM_PREC	=	CORE_MEMSET_SEL_PREC;

	assign	VECTOR_3_SEL_OP		=	CORE_VECTOR_SEL_OP;
	assign	VECTOR_3_SEL_PREC	=	CORE_VECTOR_SEL_PREC;

	assign	VECTOR_3_VECTOR_EN	=	CORE_VECTOR_EN[3];
	assign	VECTOR_3_VECTOR_LOAD_EN	=	CORE_VECTOR_LOAD_EN[3];
	assign	VECTOR_3_VECTOR_MODE	=	CORE_VECTOR_MODE;


	assign	VECTOR_4_EN_DI_0_0	=	CORE_VECTOR_LOAD_EN[4] & CORE_VECTOR_EN_DI_0_0;
	assign	VECTOR_4_EN_DI_0_1	=	CORE_VECTOR_LOAD_EN[4] & CORE_VECTOR_EN_DI_0_1;
	assign	VECTOR_4_EN_DI_1_0	=	CORE_VECTOR_LOAD_EN[4] & CORE_VECTOR_EN_DI_1_0;
	assign	VECTOR_4_EN_DI_1_1	=	CORE_VECTOR_LOAD_EN[4] & CORE_VECTOR_EN_DI_1_1;
	assign	VECTOR_4_EN_DO_0_0	=	CORE_VECTOR_EN[4] & CORE_VECTOR_EN_DO_0_0;
	assign	VECTOR_4_EN_DO_0_1	=	CORE_VECTOR_EN[4] & CORE_VECTOR_EN_DO_0_1;

	assign	VECTOR_4_SEL_DI_0_R	=	CORE_VECTOR_SEL_DI_0_R;
	assign	VECTOR_4_SEL_DI_1_R	=	CORE_VECTOR_SEL_DI_1_R;
	assign	VECTOR_4_SEL_DO_0_R	=	CORE_VECTOR_SEL_DO_0_R;
	assign	VECTOR_4_SEL_DO_0_W	=	CORE_VECTOR_SEL_DO_0_W;
	assign	VECTOR_4_SEL_DO_SUM_PREC	=	CORE_MEMSET_SEL_PREC;

	assign	VECTOR_4_SEL_OP		=	CORE_VECTOR_SEL_OP;
	assign	VECTOR_4_SEL_PREC	=	CORE_VECTOR_SEL_PREC;

	assign	VECTOR_4_VECTOR_EN	=	CORE_VECTOR_EN[4];
	assign	VECTOR_4_VECTOR_LOAD_EN	=	CORE_VECTOR_LOAD_EN[4];
	assign	VECTOR_4_VECTOR_MODE	=	CORE_VECTOR_MODE;


	assign	VECTOR_5_EN_DI_0_0	=	CORE_VECTOR_LOAD_EN[5] & CORE_VECTOR_EN_DI_0_0;
	assign	VECTOR_5_EN_DI_0_1	=	CORE_VECTOR_LOAD_EN[5] & CORE_VECTOR_EN_DI_0_1;
	assign	VECTOR_5_EN_DI_1_0	=	CORE_VECTOR_LOAD_EN[5] & CORE_VECTOR_EN_DI_1_0;
	assign	VECTOR_5_EN_DI_1_1	=	CORE_VECTOR_LOAD_EN[5] & CORE_VECTOR_EN_DI_1_1;
	assign	VECTOR_5_EN_DO_0_0	=	CORE_VECTOR_EN[5] & CORE_VECTOR_EN_DO_0_0;
	assign	VECTOR_5_EN_DO_0_1	=	CORE_VECTOR_EN[5] & CORE_VECTOR_EN_DO_0_1;

	assign	VECTOR_5_SEL_DI_0_R	=	CORE_VECTOR_SEL_DI_0_R;
	assign	VECTOR_5_SEL_DI_1_R	=	CORE_VECTOR_SEL_DI_1_R;
	assign	VECTOR_5_SEL_DO_0_R	=	CORE_VECTOR_SEL_DO_0_R;
	assign	VECTOR_5_SEL_DO_0_W	=	CORE_VECTOR_SEL_DO_0_W;
	assign	VECTOR_5_SEL_DO_SUM_PREC	=	CORE_MEMSET_SEL_PREC;

	assign	VECTOR_5_SEL_OP		=	CORE_VECTOR_SEL_OP;
	assign	VECTOR_5_SEL_PREC	=	CORE_VECTOR_SEL_PREC;

	assign	VECTOR_5_VECTOR_EN	=	CORE_VECTOR_EN[5];
	assign	VECTOR_5_VECTOR_LOAD_EN	=	CORE_VECTOR_LOAD_EN[5];
	assign	VECTOR_5_VECTOR_MODE	=	CORE_VECTOR_MODE;


	assign	VECTOR_6_EN_DI_0_0	=	CORE_VECTOR_LOAD_EN[6] & CORE_VECTOR_EN_DI_0_0;
	assign	VECTOR_6_EN_DI_0_1	=	CORE_VECTOR_LOAD_EN[6] & CORE_VECTOR_EN_DI_0_1;
	assign	VECTOR_6_EN_DI_1_0	=	CORE_VECTOR_LOAD_EN[6] & CORE_VECTOR_EN_DI_1_0;
	assign	VECTOR_6_EN_DI_1_1	=	CORE_VECTOR_LOAD_EN[6] & CORE_VECTOR_EN_DI_1_1;
	assign	VECTOR_6_EN_DO_0_0	=	CORE_VECTOR_EN[6] & CORE_VECTOR_EN_DO_0_0;
	assign	VECTOR_6_EN_DO_0_1	=	CORE_VECTOR_EN[6] & CORE_VECTOR_EN_DO_0_1;

	assign	VECTOR_6_SEL_DI_0_R	=	CORE_VECTOR_SEL_DI_0_R;
	assign	VECTOR_6_SEL_DI_1_R	=	CORE_VECTOR_SEL_DI_1_R;
	assign	VECTOR_6_SEL_DO_0_R	=	CORE_VECTOR_SEL_DO_0_R;
	assign	VECTOR_6_SEL_DO_0_W	=	CORE_VECTOR_SEL_DO_0_W;
	assign	VECTOR_6_SEL_DO_SUM_PREC	=	CORE_MEMSET_SEL_PREC;

	assign	VECTOR_6_SEL_OP		=	CORE_VECTOR_SEL_OP;
	assign	VECTOR_6_SEL_PREC	=	CORE_VECTOR_SEL_PREC;

	assign	VECTOR_6_VECTOR_EN	=	CORE_VECTOR_EN[6];
	assign	VECTOR_6_VECTOR_LOAD_EN	=	CORE_VECTOR_LOAD_EN[6];
	assign	VECTOR_6_VECTOR_MODE	=	CORE_VECTOR_MODE;


	assign	VECTOR_7_EN_DI_0_0	=	CORE_VECTOR_LOAD_EN[7] & CORE_VECTOR_EN_DI_0_0;
	assign	VECTOR_7_EN_DI_0_1	=	CORE_VECTOR_LOAD_EN[7] & CORE_VECTOR_EN_DI_0_1;
	assign	VECTOR_7_EN_DI_1_0	=	CORE_VECTOR_LOAD_EN[7] & CORE_VECTOR_EN_DI_1_0;
	assign	VECTOR_7_EN_DI_1_1	=	CORE_VECTOR_LOAD_EN[7] & CORE_VECTOR_EN_DI_1_1;
	assign	VECTOR_7_EN_DO_0_0	=	CORE_VECTOR_EN[7] & CORE_VECTOR_EN_DO_0_0;
	assign	VECTOR_7_EN_DO_0_1	=	CORE_VECTOR_EN[7] & CORE_VECTOR_EN_DO_0_1;

	assign	VECTOR_7_SEL_DI_0_R	=	CORE_VECTOR_SEL_DI_0_R;
	assign	VECTOR_7_SEL_DI_1_R	=	CORE_VECTOR_SEL_DI_1_R;
	assign	VECTOR_7_SEL_DO_0_R	=	CORE_VECTOR_SEL_DO_0_R;
	assign	VECTOR_7_SEL_DO_0_W	=	CORE_VECTOR_SEL_DO_0_W;
	assign	VECTOR_7_SEL_DO_SUM_PREC	=	CORE_MEMSET_SEL_PREC;

	assign	VECTOR_7_SEL_OP		=	CORE_VECTOR_SEL_OP;
	assign	VECTOR_7_SEL_PREC	=	CORE_VECTOR_SEL_PREC;

	assign	VECTOR_7_VECTOR_EN	=	CORE_VECTOR_EN[7];
	assign	VECTOR_7_VECTOR_LOAD_EN	=	CORE_VECTOR_LOAD_EN[7];
	assign	VECTOR_7_VECTOR_MODE	=	CORE_VECTOR_MODE;


	// MEMSET

	wire	[31:0]	MEMSET_DI_0;
	wire	[31:0]	MEMSET_DI_1;
	wire	[31:0]	MEMSET_DI_2;
	wire	[31:0]	MEMSET_DI_3;
	wire	[31:0]	MEMSET_DI_4;
	wire	[31:0]	MEMSET_DI_5;
	wire	[31:0]	MEMSET_DI_6;
	wire	[31:0]	MEMSET_DI_7;
	wire	[31:0]	MEMSET_DI_8;
	wire	[31:0]	MEMSET_DI_9;
	wire	[31:0]	MEMSET_DI_10;
	wire	[31:0]	MEMSET_DI_11;
	wire	[31:0]	MEMSET_DI_12;
	wire	[31:0]	MEMSET_DI_13;
	wire	[31:0]	MEMSET_DI_14;
	wire	[31:0]	MEMSET_DI_15;
	wire	[31:0]	MEMSET_DI_16;
	wire	[31:0]	MEMSET_DI_17;
	wire	[31:0]	MEMSET_DI_18;
	wire	[31:0]	MEMSET_DI_19;
	wire	[31:0]	MEMSET_DI_20;
	wire	[31:0]	MEMSET_DI_21;
	wire	[31:0]	MEMSET_DI_22;
	wire	[31:0]	MEMSET_DI_23;
	wire	[31:0]	MEMSET_DI_24;
	wire	[31:0]	MEMSET_DI_25;
	wire	[31:0]	MEMSET_DI_26;
	wire	[31:0]	MEMSET_DI_27;
	wire	[31:0]	MEMSET_DI_28;
	wire	[31:0]	MEMSET_DI_29;
	wire	[31:0]	MEMSET_DI_30;
	wire	[31:0]	MEMSET_DI_31;
	wire	[31:0]	MEMSET_DI_32;
	wire	[31:0]	MEMSET_DI_33;
	wire	[31:0]	MEMSET_DI_34;
	wire	[31:0]	MEMSET_DI_35;
	wire	[31:0]	MEMSET_DI_36;
	wire	[31:0]	MEMSET_DI_37;
	wire	[31:0]	MEMSET_DI_38;
	wire	[31:0]	MEMSET_DI_39;
	wire	[31:0]	MEMSET_DI_40;
	wire	[31:0]	MEMSET_DI_41;
	wire	[31:0]	MEMSET_DI_42;
	wire	[31:0]	MEMSET_DI_43;
	wire	[31:0]	MEMSET_DI_44;
	wire	[31:0]	MEMSET_DI_45;
	wire	[31:0]	MEMSET_DI_46;
	wire	[31:0]	MEMSET_DI_47;
	wire	[31:0]	MEMSET_DI_48;
	wire	[31:0]	MEMSET_DI_49;
	wire	[31:0]	MEMSET_DI_50;
	wire	[31:0]	MEMSET_DI_51;
	wire	[31:0]	MEMSET_DI_52;
	wire	[31:0]	MEMSET_DI_53;
	wire	[31:0]	MEMSET_DI_54;
	wire	[31:0]	MEMSET_DI_55;
	wire	[31:0]	MEMSET_DI_56;
	wire	[31:0]	MEMSET_DI_57;
	wire	[31:0]	MEMSET_DI_58;
	wire	[31:0]	MEMSET_DI_59;
	wire	[31:0]	MEMSET_DI_60;
	wire	[31:0]	MEMSET_DI_61;
	wire	[31:0]	MEMSET_DI_62;
	wire	[31:0]	MEMSET_DI_63;


	wire	[31:0]	MEMSET_DO_0;
	wire	[31:0]	MEMSET_DO_1;
	wire	[31:0]	MEMSET_DO_2;
	wire	[31:0]	MEMSET_DO_3;
	wire	[31:0]	MEMSET_DO_4;
	wire	[31:0]	MEMSET_DO_5;
	wire	[31:0]	MEMSET_DO_6;
	wire	[31:0]	MEMSET_DO_7;
	wire	[31:0]	MEMSET_DO_8;
	wire	[31:0]	MEMSET_DO_9;
	wire	[31:0]	MEMSET_DO_10;
	wire	[31:0]	MEMSET_DO_11;
	wire	[31:0]	MEMSET_DO_12;
	wire	[31:0]	MEMSET_DO_13;
	wire	[31:0]	MEMSET_DO_14;
	wire	[31:0]	MEMSET_DO_15;
	wire	[31:0]	MEMSET_DO_16;
	wire	[31:0]	MEMSET_DO_17;
	wire	[31:0]	MEMSET_DO_18;
	wire	[31:0]	MEMSET_DO_19;
	wire	[31:0]	MEMSET_DO_20;
	wire	[31:0]	MEMSET_DO_21;
	wire	[31:0]	MEMSET_DO_22;
	wire	[31:0]	MEMSET_DO_23;
	wire	[31:0]	MEMSET_DO_24;
	wire	[31:0]	MEMSET_DO_25;
	wire	[31:0]	MEMSET_DO_26;
	wire	[31:0]	MEMSET_DO_27;
	wire	[31:0]	MEMSET_DO_28;
	wire	[31:0]	MEMSET_DO_29;
	wire	[31:0]	MEMSET_DO_30;
	wire	[31:0]	MEMSET_DO_31;
	wire	[31:0]	MEMSET_DO_32;
	wire	[31:0]	MEMSET_DO_33;
	wire	[31:0]	MEMSET_DO_34;
	wire	[31:0]	MEMSET_DO_35;
	wire	[31:0]	MEMSET_DO_36;
	wire	[31:0]	MEMSET_DO_37;
	wire	[31:0]	MEMSET_DO_38;
	wire	[31:0]	MEMSET_DO_39;
	wire	[31:0]	MEMSET_DO_40;
	wire	[31:0]	MEMSET_DO_41;
	wire	[31:0]	MEMSET_DO_42;
	wire	[31:0]	MEMSET_DO_43;
	wire	[31:0]	MEMSET_DO_44;
	wire	[31:0]	MEMSET_DO_45;
	wire	[31:0]	MEMSET_DO_46;
	wire	[31:0]	MEMSET_DO_47;
	wire	[31:0]	MEMSET_DO_48;
	wire	[31:0]	MEMSET_DO_49;
	wire	[31:0]	MEMSET_DO_50;
	wire	[31:0]	MEMSET_DO_51;
	wire	[31:0]	MEMSET_DO_52;
	wire	[31:0]	MEMSET_DO_53;
	wire	[31:0]	MEMSET_DO_54;
	wire	[31:0]	MEMSET_DO_55;
	wire	[31:0]	MEMSET_DO_56;
	wire	[31:0]	MEMSET_DO_57;
	wire	[31:0]	MEMSET_DO_58;
	wire	[31:0]	MEMSET_DO_59;
	wire	[31:0]	MEMSET_DO_60;
	wire	[31:0]	MEMSET_DO_61;
	wire	[31:0]	MEMSET_DO_62;
	wire	[31:0]	MEMSET_DO_63;

	wire	[8+6:0]	MEMSET_ADDR;
	wire	[31:0]	MEMSET_BE;
	wire		MEMSET_WEN;
	wire	[63:0]	MEMSET_CSN;

	wire		MEMSET_SEL_MODE;
	wire		MEMSET_SEL_PREC;
	wire	[2:0]	MEMSET_SEL_BLOCK;
	wire	[2:0]	MEMSET_SEL_BLOCK_LOAD;

	
	MEMSET memset_0 (
		.DI_0(MEMSET_DI_0),
		.DI_1(MEMSET_DI_1),
		.DI_2(MEMSET_DI_2),
		.DI_3(MEMSET_DI_3),
		.DI_4(MEMSET_DI_4),
		.DI_5(MEMSET_DI_5),
		.DI_6(MEMSET_DI_6),
		.DI_7(MEMSET_DI_7),
		.DI_8(MEMSET_DI_8),
		.DI_9(MEMSET_DI_9),
		.DI_10(MEMSET_DI_10),
		.DI_11(MEMSET_DI_11),
		.DI_12(MEMSET_DI_12),
		.DI_13(MEMSET_DI_13),
		.DI_14(MEMSET_DI_14),
		.DI_15(MEMSET_DI_15),
		.DI_16(MEMSET_DI_16),
		.DI_17(MEMSET_DI_17),
		.DI_18(MEMSET_DI_18),
		.DI_19(MEMSET_DI_19),
		.DI_20(MEMSET_DI_20),
		.DI_21(MEMSET_DI_21),
		.DI_22(MEMSET_DI_22),
		.DI_23(MEMSET_DI_23),
		.DI_24(MEMSET_DI_24),
		.DI_25(MEMSET_DI_25),
		.DI_26(MEMSET_DI_26),
		.DI_27(MEMSET_DI_27),
		.DI_28(MEMSET_DI_28),
		.DI_29(MEMSET_DI_29),
		.DI_30(MEMSET_DI_30),
		.DI_31(MEMSET_DI_31),
		.DI_32(MEMSET_DI_32),
		.DI_33(MEMSET_DI_33),
		.DI_34(MEMSET_DI_34),
		.DI_35(MEMSET_DI_35),
		.DI_36(MEMSET_DI_36),
		.DI_37(MEMSET_DI_37),
		.DI_38(MEMSET_DI_38),
		.DI_39(MEMSET_DI_39),
		.DI_40(MEMSET_DI_40),
		.DI_41(MEMSET_DI_41),
		.DI_42(MEMSET_DI_42),
		.DI_43(MEMSET_DI_43),
		.DI_44(MEMSET_DI_44),
		.DI_45(MEMSET_DI_45),
		.DI_46(MEMSET_DI_46),
		.DI_47(MEMSET_DI_47),
		.DI_48(MEMSET_DI_48),
		.DI_49(MEMSET_DI_49),
		.DI_50(MEMSET_DI_50),
		.DI_51(MEMSET_DI_51),
		.DI_52(MEMSET_DI_52),
		.DI_53(MEMSET_DI_53),
		.DI_54(MEMSET_DI_54),
		.DI_55(MEMSET_DI_55),
		.DI_56(MEMSET_DI_56),
		.DI_57(MEMSET_DI_57),
		.DI_58(MEMSET_DI_58),
		.DI_59(MEMSET_DI_59),
		.DI_60(MEMSET_DI_60),
		.DI_61(MEMSET_DI_61),
		.DI_62(MEMSET_DI_62),
		.DI_63(MEMSET_DI_63),

		.DO_0(MEMSET_DO_0),
		.DO_1(MEMSET_DO_1),
		.DO_2(MEMSET_DO_2),
		.DO_3(MEMSET_DO_3),
		.DO_4(MEMSET_DO_4),
		.DO_5(MEMSET_DO_5),
		.DO_6(MEMSET_DO_6),
		.DO_7(MEMSET_DO_7),
		.DO_8(MEMSET_DO_8),
		.DO_9(MEMSET_DO_9),
		.DO_10(MEMSET_DO_10),
		.DO_11(MEMSET_DO_11),
		.DO_12(MEMSET_DO_12),
		.DO_13(MEMSET_DO_13),
		.DO_14(MEMSET_DO_14),
		.DO_15(MEMSET_DO_15),
		.DO_16(MEMSET_DO_16),
		.DO_17(MEMSET_DO_17),
		.DO_18(MEMSET_DO_18),
		.DO_19(MEMSET_DO_19),
		.DO_20(MEMSET_DO_20),
		.DO_21(MEMSET_DO_21),
		.DO_22(MEMSET_DO_22),
		.DO_23(MEMSET_DO_23),
		.DO_24(MEMSET_DO_24),
		.DO_25(MEMSET_DO_25),
		.DO_26(MEMSET_DO_26),
		.DO_27(MEMSET_DO_27),
		.DO_28(MEMSET_DO_28),
		.DO_29(MEMSET_DO_29),
		.DO_30(MEMSET_DO_30),
		.DO_31(MEMSET_DO_31),
		.DO_32(MEMSET_DO_32),
		.DO_33(MEMSET_DO_33),
		.DO_34(MEMSET_DO_34),
		.DO_35(MEMSET_DO_35),
		.DO_36(MEMSET_DO_36),
		.DO_37(MEMSET_DO_37),
		.DO_38(MEMSET_DO_38),
		.DO_39(MEMSET_DO_39),
		.DO_40(MEMSET_DO_40),
		.DO_41(MEMSET_DO_41),
		.DO_42(MEMSET_DO_42),
		.DO_43(MEMSET_DO_43),
		.DO_44(MEMSET_DO_44),
		.DO_45(MEMSET_DO_45),
		.DO_46(MEMSET_DO_46),
		.DO_47(MEMSET_DO_47),
		.DO_48(MEMSET_DO_48),
		.DO_49(MEMSET_DO_49),
		.DO_50(MEMSET_DO_50),
		.DO_51(MEMSET_DO_51),
		.DO_52(MEMSET_DO_52),
		.DO_53(MEMSET_DO_53),
		.DO_54(MEMSET_DO_54),
		.DO_55(MEMSET_DO_55),
		.DO_56(MEMSET_DO_56),
		.DO_57(MEMSET_DO_57),
		.DO_58(MEMSET_DO_58),
		.DO_59(MEMSET_DO_59),
		.DO_60(MEMSET_DO_60),
		.DO_61(MEMSET_DO_61),
		.DO_62(MEMSET_DO_62),
		.DO_63(MEMSET_DO_63),

		.ADDR(MEMSET_ADDR),
		.BE(MEMSET_BE),
		.WEN(MEMSET_WEN),
		.CSN(MEMSET_CSN),

		.SEL_MODE(MEMSET_SEL_MODE),
		.SEL_PREC(MEMSET_SEL_PREC),
		.SEL_BLOCK(MEMSET_SEL_BLOCK),
		.SEL_BLOCK_LOAD(MEMSET_SEL_BLOCK_LOAD),

		.CLK(CLK),
		.RSTn(RSTn)	
	);



	wire	[8+6:0]	FF_MEMSET_INIT_CNT_D, FF_MEMSET_INIT_CNT_Q;

	PipeReg #(15) FF_MEMSET_INIT_CNT (
		.CLK(CLK),
		.RST(~RSTn),
		.EN(1'b1),
		.D(FF_MEMSET_INIT_CNT_D),
		.Q(FF_MEMSET_INIT_CNT_Q));

	assign	FF_MEMSET_INIT_CNT_D	=	(((ADDR == 2'b10) & ~WEN) | ((ADDR == 2'b11) & WEN))	? FF_MEMSET_INIT_CNT_Q + 15'd1 :
						15'd0;

	wire	[63:0]	MEMSET_INIT_CSN;

	assign	MEMSET_INIT_CSN[0]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd0);
	assign	MEMSET_INIT_CSN[1]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd1);
	assign	MEMSET_INIT_CSN[2]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd2);
	assign	MEMSET_INIT_CSN[3]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd3);
	assign	MEMSET_INIT_CSN[4]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd4);
	assign	MEMSET_INIT_CSN[5]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd5);
	assign	MEMSET_INIT_CSN[6]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd6);
	assign	MEMSET_INIT_CSN[7]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd7);
	assign	MEMSET_INIT_CSN[8]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd8);
	assign	MEMSET_INIT_CSN[9]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd9);
	assign	MEMSET_INIT_CSN[10]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd10);
	assign	MEMSET_INIT_CSN[11]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd11);
	assign	MEMSET_INIT_CSN[12]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd12);
	assign	MEMSET_INIT_CSN[13]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd13);
	assign	MEMSET_INIT_CSN[14]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd14);
	assign	MEMSET_INIT_CSN[15]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd15);
	assign	MEMSET_INIT_CSN[16]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd16);
	assign	MEMSET_INIT_CSN[17]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd17);
	assign	MEMSET_INIT_CSN[18]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd18);
	assign	MEMSET_INIT_CSN[19]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd19);
	assign	MEMSET_INIT_CSN[20]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd20);
	assign	MEMSET_INIT_CSN[21]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd21);
	assign	MEMSET_INIT_CSN[22]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd22);
	assign	MEMSET_INIT_CSN[23]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd23);
	assign	MEMSET_INIT_CSN[24]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd24);
	assign	MEMSET_INIT_CSN[25]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd25);
	assign	MEMSET_INIT_CSN[26]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd26);
	assign	MEMSET_INIT_CSN[27]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd27);
	assign	MEMSET_INIT_CSN[28]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd28);
	assign	MEMSET_INIT_CSN[29]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd29);
	assign	MEMSET_INIT_CSN[30]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd30);
	assign	MEMSET_INIT_CSN[31]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd31);
	assign	MEMSET_INIT_CSN[32]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd32);
	assign	MEMSET_INIT_CSN[33]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd33);
	assign	MEMSET_INIT_CSN[34]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd34);
	assign	MEMSET_INIT_CSN[35]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd35);
	assign	MEMSET_INIT_CSN[36]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd36);
	assign	MEMSET_INIT_CSN[37]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd37);
	assign	MEMSET_INIT_CSN[38]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd38);
	assign	MEMSET_INIT_CSN[39]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd39);
	assign	MEMSET_INIT_CSN[40]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd40);
	assign	MEMSET_INIT_CSN[41]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd41);
	assign	MEMSET_INIT_CSN[42]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd42);
	assign	MEMSET_INIT_CSN[43]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd43);
	assign	MEMSET_INIT_CSN[44]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd44);
	assign	MEMSET_INIT_CSN[45]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd45);
	assign	MEMSET_INIT_CSN[46]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd46);
	assign	MEMSET_INIT_CSN[47]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd47);
	assign	MEMSET_INIT_CSN[48]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd48);
	assign	MEMSET_INIT_CSN[49]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd49);
	assign	MEMSET_INIT_CSN[50]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd50);
	assign	MEMSET_INIT_CSN[51]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd51);
	assign	MEMSET_INIT_CSN[52]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd52);
	assign	MEMSET_INIT_CSN[53]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd53);
	assign	MEMSET_INIT_CSN[54]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd54);
	assign	MEMSET_INIT_CSN[55]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd55);
	assign	MEMSET_INIT_CSN[56]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd56);
	assign	MEMSET_INIT_CSN[57]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd57);
	assign	MEMSET_INIT_CSN[58]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd58);
	assign	MEMSET_INIT_CSN[59]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd59);
	assign	MEMSET_INIT_CSN[60]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd60);
	assign	MEMSET_INIT_CSN[61]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd61);
	assign	MEMSET_INIT_CSN[62]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd62);
	assign	MEMSET_INIT_CSN[63]	=	~(FF_MEMSET_INIT_CNT_Q[5:0] == 6'd63);


	assign	CORE_DMEM_DO		=	MEMSET_DO_0;

	assign	MEMSET_ADDR		=	((ADDR == 2'b10) & ~WEN)	? FF_MEMSET_INIT_CNT_Q :
						((ADDR == 2'b11) & WEN)	? FF_MEMSET_INIT_CNT_Q :
						CORE_DMEM_ADDR;
	assign	MEMSET_WEN		=	((ADDR == 2'b10) & ~WEN)	? 1'b0 :
						((ADDR == 2'b11) & WEN)	? 1'b1 :
						CORE_DMEM_WEN;
	assign	MEMSET_CSN		=	((ADDR == 2'b10) & ~WEN)	? MEMSET_INIT_CSN :
						((ADDR == 2'b11) & WEN)	? MEMSET_INIT_CSN :
						CORE_DMEM_CSN;
	assign	MEMSET_BE		=	((ADDR == 2'b10) & ~WEN)	? 32'hFFFF_FFFF :
						((ADDR == 2'b11) & WEN)	? 32'hFFFF_FFFF :
						CORE_DMEM_BE;
	assign	MEMSET_SEL_MODE		=	((ADDR == 2'b10) & ~WEN)	? 1'b1 :
						((ADDR == 2'b11) & WEN)	? 1'b1 :
						CORE_MEMSET_SEL_MODE;
	assign	MEMSET_SEL_PREC		=	((ADDR == 2'b10) & ~WEN)	? 1'b0 :
						((ADDR == 2'b11) & WEN)	? 1'b0 :
						CORE_MEMSET_SEL_PREC;
	assign	MEMSET_SEL_BLOCK	=	((ADDR == 2'b10) & ~WEN)	? 3'b000 :
						((ADDR == 2'b11) & WEN) ? 3'b000 :
						CORE_MEMSET_SEL_BLOCK;

	assign	DO			=	((ADDR == 2'b00) & WEN) ? {30'd0, FF_CORE_END_Q, FF_CORE_EN_Q}:
						((ADDR == 2'b11) & WEN)	? MEMSET_DO_0 : 
						32'd0;


	assign	VECTOR_0_DI_0_00	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_0;
	assign	VECTOR_0_DI_0_01	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_1;
	assign	VECTOR_0_DI_0_02	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_2;
	assign	VECTOR_0_DI_0_03	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_3;
	assign	VECTOR_0_DI_0_04	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_4;
	assign	VECTOR_0_DI_0_05	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_5;
	assign	VECTOR_0_DI_0_06	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_6;
	assign	VECTOR_0_DI_0_07	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_7;
	assign	VECTOR_0_DI_0_08	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_8;
	assign	VECTOR_0_DI_0_09	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_9;
	assign	VECTOR_0_DI_0_10	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_10;
	assign	VECTOR_0_DI_0_11	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_11;
	assign	VECTOR_0_DI_0_12	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_12;
	assign	VECTOR_0_DI_0_13	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_13;
	assign	VECTOR_0_DI_0_14	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_14;
	assign	VECTOR_0_DI_0_15	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_15;
	assign	VECTOR_0_DI_0_16	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_16;
	assign	VECTOR_0_DI_0_17	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_17;
	assign	VECTOR_0_DI_0_18	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_18;
	assign	VECTOR_0_DI_0_19	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_19;
	assign	VECTOR_0_DI_0_20	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_20;
	assign	VECTOR_0_DI_0_21	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_21;
	assign	VECTOR_0_DI_0_22	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_22;
	assign	VECTOR_0_DI_0_23	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_23;
	assign	VECTOR_0_DI_0_24	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_24;
	assign	VECTOR_0_DI_0_25	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_25;
	assign	VECTOR_0_DI_0_26	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_26;
	assign	VECTOR_0_DI_0_27	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_27;
	assign	VECTOR_0_DI_0_28	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_28;
	assign	VECTOR_0_DI_0_29	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_29;
	assign	VECTOR_0_DI_0_30	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_30;
	assign	VECTOR_0_DI_0_31	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_31;
	assign	VECTOR_0_DI_0_32	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_32;
	assign	VECTOR_0_DI_0_33	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_33;
	assign	VECTOR_0_DI_0_34	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_34;
	assign	VECTOR_0_DI_0_35	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_35;
	assign	VECTOR_0_DI_0_36	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_36;
	assign	VECTOR_0_DI_0_37	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_37;
	assign	VECTOR_0_DI_0_38	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_38;
	assign	VECTOR_0_DI_0_39	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_39;
	assign	VECTOR_0_DI_0_40	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_40;
	assign	VECTOR_0_DI_0_41	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_41;
	assign	VECTOR_0_DI_0_42	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_42;
	assign	VECTOR_0_DI_0_43	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_43;
	assign	VECTOR_0_DI_0_44	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_44;
	assign	VECTOR_0_DI_0_45	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_45;
	assign	VECTOR_0_DI_0_46	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_46;
	assign	VECTOR_0_DI_0_47	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_47;
	assign	VECTOR_0_DI_0_48	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_48;
	assign	VECTOR_0_DI_0_49	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_49;
	assign	VECTOR_0_DI_0_50	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_50;
	assign	VECTOR_0_DI_0_51	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_51;
	assign	VECTOR_0_DI_0_52	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_52;
	assign	VECTOR_0_DI_0_53	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_53;
	assign	VECTOR_0_DI_0_54	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_54;
	assign	VECTOR_0_DI_0_55	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_55;
	assign	VECTOR_0_DI_0_56	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_56;
	assign	VECTOR_0_DI_0_57	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_57;
	assign	VECTOR_0_DI_0_58	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_58;
	assign	VECTOR_0_DI_0_59	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_59;
	assign	VECTOR_0_DI_0_60	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_60;
	assign	VECTOR_0_DI_0_61	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_61;
	assign	VECTOR_0_DI_0_62	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_62;
	assign	VECTOR_0_DI_0_63	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_63;
	
	assign	VECTOR_1_DI_0_00	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_0;
	assign	VECTOR_1_DI_0_01	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_1;
	assign	VECTOR_1_DI_0_02	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_2;
	assign	VECTOR_1_DI_0_03	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_3;
	assign	VECTOR_1_DI_0_04	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_4;
	assign	VECTOR_1_DI_0_05	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_5;
	assign	VECTOR_1_DI_0_06	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_6;
	assign	VECTOR_1_DI_0_07	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_7;
	assign	VECTOR_1_DI_0_08	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_8;
	assign	VECTOR_1_DI_0_09	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_9;
	assign	VECTOR_1_DI_0_10	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_10;
	assign	VECTOR_1_DI_0_11	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_11;
	assign	VECTOR_1_DI_0_12	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_12;
	assign	VECTOR_1_DI_0_13	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_13;
	assign	VECTOR_1_DI_0_14	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_14;
	assign	VECTOR_1_DI_0_15	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_15;
	assign	VECTOR_1_DI_0_16	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_16;
	assign	VECTOR_1_DI_0_17	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_17;
	assign	VECTOR_1_DI_0_18	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_18;
	assign	VECTOR_1_DI_0_19	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_19;
	assign	VECTOR_1_DI_0_20	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_20;
	assign	VECTOR_1_DI_0_21	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_21;
	assign	VECTOR_1_DI_0_22	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_22;
	assign	VECTOR_1_DI_0_23	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_23;
	assign	VECTOR_1_DI_0_24	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_24;
	assign	VECTOR_1_DI_0_25	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_25;
	assign	VECTOR_1_DI_0_26	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_26;
	assign	VECTOR_1_DI_0_27	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_27;
	assign	VECTOR_1_DI_0_28	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_28;
	assign	VECTOR_1_DI_0_29	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_29;
	assign	VECTOR_1_DI_0_30	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_30;
	assign	VECTOR_1_DI_0_31	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_31;
	assign	VECTOR_1_DI_0_32	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_32;
	assign	VECTOR_1_DI_0_33	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_33;
	assign	VECTOR_1_DI_0_34	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_34;
	assign	VECTOR_1_DI_0_35	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_35;
	assign	VECTOR_1_DI_0_36	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_36;
	assign	VECTOR_1_DI_0_37	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_37;
	assign	VECTOR_1_DI_0_38	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_38;
	assign	VECTOR_1_DI_0_39	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_39;
	assign	VECTOR_1_DI_0_40	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_40;
	assign	VECTOR_1_DI_0_41	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_41;
	assign	VECTOR_1_DI_0_42	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_42;
	assign	VECTOR_1_DI_0_43	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_43;
	assign	VECTOR_1_DI_0_44	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_44;
	assign	VECTOR_1_DI_0_45	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_45;
	assign	VECTOR_1_DI_0_46	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_46;
	assign	VECTOR_1_DI_0_47	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_47;
	assign	VECTOR_1_DI_0_48	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_48;
	assign	VECTOR_1_DI_0_49	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_49;
	assign	VECTOR_1_DI_0_50	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_50;
	assign	VECTOR_1_DI_0_51	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_51;
	assign	VECTOR_1_DI_0_52	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_52;
	assign	VECTOR_1_DI_0_53	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_53;
	assign	VECTOR_1_DI_0_54	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_54;
	assign	VECTOR_1_DI_0_55	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_55;
	assign	VECTOR_1_DI_0_56	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_56;
	assign	VECTOR_1_DI_0_57	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_57;
	assign	VECTOR_1_DI_0_58	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_58;
	assign	VECTOR_1_DI_0_59	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_59;
	assign	VECTOR_1_DI_0_60	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_60;
	assign	VECTOR_1_DI_0_61	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_61;
	assign	VECTOR_1_DI_0_62	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_62;
	assign	VECTOR_1_DI_0_63	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_63;

	assign	VECTOR_2_DI_0_00	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_0;
	assign	VECTOR_2_DI_0_01	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_1;
	assign	VECTOR_2_DI_0_02	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_2;
	assign	VECTOR_2_DI_0_03	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_3;
	assign	VECTOR_2_DI_0_04	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_4;
	assign	VECTOR_2_DI_0_05	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_5;
	assign	VECTOR_2_DI_0_06	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_6;
	assign	VECTOR_2_DI_0_07	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_7;
	assign	VECTOR_2_DI_0_08	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_8;
	assign	VECTOR_2_DI_0_09	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_9;
	assign	VECTOR_2_DI_0_10	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_10;
	assign	VECTOR_2_DI_0_11	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_11;
	assign	VECTOR_2_DI_0_12	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_12;
	assign	VECTOR_2_DI_0_13	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_13;
	assign	VECTOR_2_DI_0_14	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_14;
	assign	VECTOR_2_DI_0_15	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_15;
	assign	VECTOR_2_DI_0_16	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_16;
	assign	VECTOR_2_DI_0_17	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_17;
	assign	VECTOR_2_DI_0_18	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_18;
	assign	VECTOR_2_DI_0_19	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_19;
	assign	VECTOR_2_DI_0_20	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_20;
	assign	VECTOR_2_DI_0_21	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_21;
	assign	VECTOR_2_DI_0_22	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_22;
	assign	VECTOR_2_DI_0_23	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_23;
	assign	VECTOR_2_DI_0_24	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_24;
	assign	VECTOR_2_DI_0_25	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_25;
	assign	VECTOR_2_DI_0_26	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_26;
	assign	VECTOR_2_DI_0_27	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_27;
	assign	VECTOR_2_DI_0_28	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_28;
	assign	VECTOR_2_DI_0_29	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_29;
	assign	VECTOR_2_DI_0_30	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_30;
	assign	VECTOR_2_DI_0_31	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_31;
	assign	VECTOR_2_DI_0_32	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_32;
	assign	VECTOR_2_DI_0_33	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_33;
	assign	VECTOR_2_DI_0_34	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_34;
	assign	VECTOR_2_DI_0_35	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_35;
	assign	VECTOR_2_DI_0_36	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_36;
	assign	VECTOR_2_DI_0_37	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_37;
	assign	VECTOR_2_DI_0_38	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_38;
	assign	VECTOR_2_DI_0_39	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_39;
	assign	VECTOR_2_DI_0_40	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_40;
	assign	VECTOR_2_DI_0_41	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_41;
	assign	VECTOR_2_DI_0_42	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_42;
	assign	VECTOR_2_DI_0_43	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_43;
	assign	VECTOR_2_DI_0_44	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_44;
	assign	VECTOR_2_DI_0_45	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_45;
	assign	VECTOR_2_DI_0_46	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_46;
	assign	VECTOR_2_DI_0_47	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_47;
	assign	VECTOR_2_DI_0_48	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_48;
	assign	VECTOR_2_DI_0_49	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_49;
	assign	VECTOR_2_DI_0_50	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_50;
	assign	VECTOR_2_DI_0_51	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_51;
	assign	VECTOR_2_DI_0_52	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_52;
	assign	VECTOR_2_DI_0_53	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_53;
	assign	VECTOR_2_DI_0_54	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_54;
	assign	VECTOR_2_DI_0_55	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_55;
	assign	VECTOR_2_DI_0_56	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_56;
	assign	VECTOR_2_DI_0_57	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_57;
	assign	VECTOR_2_DI_0_58	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_58;
	assign	VECTOR_2_DI_0_59	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_59;
	assign	VECTOR_2_DI_0_60	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_60;
	assign	VECTOR_2_DI_0_61	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_61;
	assign	VECTOR_2_DI_0_62	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_62;
	assign	VECTOR_2_DI_0_63	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_63;

	assign	VECTOR_3_DI_0_00	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_0;
	assign	VECTOR_3_DI_0_01	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_1;
	assign	VECTOR_3_DI_0_02	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_2;
	assign	VECTOR_3_DI_0_03	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_3;
	assign	VECTOR_3_DI_0_04	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_4;
	assign	VECTOR_3_DI_0_05	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_5;
	assign	VECTOR_3_DI_0_06	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_6;
	assign	VECTOR_3_DI_0_07	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_7;
	assign	VECTOR_3_DI_0_08	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_8;
	assign	VECTOR_3_DI_0_09	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_9;
	assign	VECTOR_3_DI_0_10	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_10;
	assign	VECTOR_3_DI_0_11	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_11;
	assign	VECTOR_3_DI_0_12	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_12;
	assign	VECTOR_3_DI_0_13	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_13;
	assign	VECTOR_3_DI_0_14	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_14;
	assign	VECTOR_3_DI_0_15	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_15;
	assign	VECTOR_3_DI_0_16	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_16;
	assign	VECTOR_3_DI_0_17	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_17;
	assign	VECTOR_3_DI_0_18	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_18;
	assign	VECTOR_3_DI_0_19	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_19;
	assign	VECTOR_3_DI_0_20	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_20;
	assign	VECTOR_3_DI_0_21	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_21;
	assign	VECTOR_3_DI_0_22	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_22;
	assign	VECTOR_3_DI_0_23	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_23;
	assign	VECTOR_3_DI_0_24	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_24;
	assign	VECTOR_3_DI_0_25	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_25;
	assign	VECTOR_3_DI_0_26	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_26;
	assign	VECTOR_3_DI_0_27	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_27;
	assign	VECTOR_3_DI_0_28	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_28;
	assign	VECTOR_3_DI_0_29	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_29;
	assign	VECTOR_3_DI_0_30	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_30;
	assign	VECTOR_3_DI_0_31	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_31;
	assign	VECTOR_3_DI_0_32	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_32;
	assign	VECTOR_3_DI_0_33	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_33;
	assign	VECTOR_3_DI_0_34	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_34;
	assign	VECTOR_3_DI_0_35	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_35;
	assign	VECTOR_3_DI_0_36	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_36;
	assign	VECTOR_3_DI_0_37	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_37;
	assign	VECTOR_3_DI_0_38	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_38;
	assign	VECTOR_3_DI_0_39	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_39;
	assign	VECTOR_3_DI_0_40	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_40;
	assign	VECTOR_3_DI_0_41	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_41;
	assign	VECTOR_3_DI_0_42	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_42;
	assign	VECTOR_3_DI_0_43	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_43;
	assign	VECTOR_3_DI_0_44	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_44;
	assign	VECTOR_3_DI_0_45	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_45;
	assign	VECTOR_3_DI_0_46	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_46;
	assign	VECTOR_3_DI_0_47	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_47;
	assign	VECTOR_3_DI_0_48	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_48;
	assign	VECTOR_3_DI_0_49	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_49;
	assign	VECTOR_3_DI_0_50	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_50;
	assign	VECTOR_3_DI_0_51	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_51;
	assign	VECTOR_3_DI_0_52	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_52;
	assign	VECTOR_3_DI_0_53	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_53;
	assign	VECTOR_3_DI_0_54	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_54;
	assign	VECTOR_3_DI_0_55	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_55;
	assign	VECTOR_3_DI_0_56	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_56;
	assign	VECTOR_3_DI_0_57	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_57;
	assign	VECTOR_3_DI_0_58	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_58;
	assign	VECTOR_3_DI_0_59	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_59;
	assign	VECTOR_3_DI_0_60	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_60;
	assign	VECTOR_3_DI_0_61	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_61;
	assign	VECTOR_3_DI_0_62	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_62;
	assign	VECTOR_3_DI_0_63	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_63;

	assign	VECTOR_4_DI_0_00	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_0;
	assign	VECTOR_4_DI_0_01	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_1;
	assign	VECTOR_4_DI_0_02	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_2;
	assign	VECTOR_4_DI_0_03	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_3;
	assign	VECTOR_4_DI_0_04	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_4;
	assign	VECTOR_4_DI_0_05	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_5;
	assign	VECTOR_4_DI_0_06	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_6;
	assign	VECTOR_4_DI_0_07	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_7;
	assign	VECTOR_4_DI_0_08	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_8;
	assign	VECTOR_4_DI_0_09	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_9;
	assign	VECTOR_4_DI_0_10	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_10;
	assign	VECTOR_4_DI_0_11	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_11;
	assign	VECTOR_4_DI_0_12	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_12;
	assign	VECTOR_4_DI_0_13	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_13;
	assign	VECTOR_4_DI_0_14	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_14;
	assign	VECTOR_4_DI_0_15	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_15;
	assign	VECTOR_4_DI_0_16	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_16;
	assign	VECTOR_4_DI_0_17	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_17;
	assign	VECTOR_4_DI_0_18	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_18;
	assign	VECTOR_4_DI_0_19	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_19;
	assign	VECTOR_4_DI_0_20	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_20;
	assign	VECTOR_4_DI_0_21	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_21;
	assign	VECTOR_4_DI_0_22	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_22;
	assign	VECTOR_4_DI_0_23	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_23;
	assign	VECTOR_4_DI_0_24	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_24;
	assign	VECTOR_4_DI_0_25	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_25;
	assign	VECTOR_4_DI_0_26	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_26;
	assign	VECTOR_4_DI_0_27	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_27;
	assign	VECTOR_4_DI_0_28	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_28;
	assign	VECTOR_4_DI_0_29	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_29;
	assign	VECTOR_4_DI_0_30	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_30;
	assign	VECTOR_4_DI_0_31	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_31;
	assign	VECTOR_4_DI_0_32	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_32;
	assign	VECTOR_4_DI_0_33	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_33;
	assign	VECTOR_4_DI_0_34	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_34;
	assign	VECTOR_4_DI_0_35	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_35;
	assign	VECTOR_4_DI_0_36	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_36;
	assign	VECTOR_4_DI_0_37	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_37;
	assign	VECTOR_4_DI_0_38	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_38;
	assign	VECTOR_4_DI_0_39	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_39;
	assign	VECTOR_4_DI_0_40	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_40;
	assign	VECTOR_4_DI_0_41	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_41;
	assign	VECTOR_4_DI_0_42	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_42;
	assign	VECTOR_4_DI_0_43	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_43;
	assign	VECTOR_4_DI_0_44	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_44;
	assign	VECTOR_4_DI_0_45	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_45;
	assign	VECTOR_4_DI_0_46	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_46;
	assign	VECTOR_4_DI_0_47	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_47;
	assign	VECTOR_4_DI_0_48	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_48;
	assign	VECTOR_4_DI_0_49	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_49;
	assign	VECTOR_4_DI_0_50	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_50;
	assign	VECTOR_4_DI_0_51	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_51;
	assign	VECTOR_4_DI_0_52	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_52;
	assign	VECTOR_4_DI_0_53	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_53;
	assign	VECTOR_4_DI_0_54	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_54;
	assign	VECTOR_4_DI_0_55	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_55;
	assign	VECTOR_4_DI_0_56	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_56;
	assign	VECTOR_4_DI_0_57	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_57;
	assign	VECTOR_4_DI_0_58	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_58;
	assign	VECTOR_4_DI_0_59	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_59;
	assign	VECTOR_4_DI_0_60	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_60;
	assign	VECTOR_4_DI_0_61	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_61;
	assign	VECTOR_4_DI_0_62	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_62;
	assign	VECTOR_4_DI_0_63	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_63;

	assign	VECTOR_5_DI_0_00	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_0;
	assign	VECTOR_5_DI_0_01	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_1;
	assign	VECTOR_5_DI_0_02	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_2;
	assign	VECTOR_5_DI_0_03	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_3;
	assign	VECTOR_5_DI_0_04	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_4;
	assign	VECTOR_5_DI_0_05	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_5;
	assign	VECTOR_5_DI_0_06	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_6;
	assign	VECTOR_5_DI_0_07	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_7;
	assign	VECTOR_5_DI_0_08	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_8;
	assign	VECTOR_5_DI_0_09	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_9;
	assign	VECTOR_5_DI_0_10	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_10;
	assign	VECTOR_5_DI_0_11	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_11;
	assign	VECTOR_5_DI_0_12	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_12;
	assign	VECTOR_5_DI_0_13	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_13;
	assign	VECTOR_5_DI_0_14	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_14;
	assign	VECTOR_5_DI_0_15	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_15;
	assign	VECTOR_5_DI_0_16	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_16;
	assign	VECTOR_5_DI_0_17	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_17;
	assign	VECTOR_5_DI_0_18	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_18;
	assign	VECTOR_5_DI_0_19	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_19;
	assign	VECTOR_5_DI_0_20	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_20;
	assign	VECTOR_5_DI_0_21	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_21;
	assign	VECTOR_5_DI_0_22	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_22;
	assign	VECTOR_5_DI_0_23	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_23;
	assign	VECTOR_5_DI_0_24	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_24;
	assign	VECTOR_5_DI_0_25	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_25;
	assign	VECTOR_5_DI_0_26	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_26;
	assign	VECTOR_5_DI_0_27	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_27;
	assign	VECTOR_5_DI_0_28	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_28;
	assign	VECTOR_5_DI_0_29	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_29;
	assign	VECTOR_5_DI_0_30	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_30;
	assign	VECTOR_5_DI_0_31	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_31;
	assign	VECTOR_5_DI_0_32	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_32;
	assign	VECTOR_5_DI_0_33	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_33;
	assign	VECTOR_5_DI_0_34	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_34;
	assign	VECTOR_5_DI_0_35	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_35;
	assign	VECTOR_5_DI_0_36	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_36;
	assign	VECTOR_5_DI_0_37	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_37;
	assign	VECTOR_5_DI_0_38	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_38;
	assign	VECTOR_5_DI_0_39	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_39;
	assign	VECTOR_5_DI_0_40	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_40;
	assign	VECTOR_5_DI_0_41	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_41;
	assign	VECTOR_5_DI_0_42	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_42;
	assign	VECTOR_5_DI_0_43	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_43;
	assign	VECTOR_5_DI_0_44	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_44;
	assign	VECTOR_5_DI_0_45	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_45;
	assign	VECTOR_5_DI_0_46	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_46;
	assign	VECTOR_5_DI_0_47	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_47;
	assign	VECTOR_5_DI_0_48	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_48;
	assign	VECTOR_5_DI_0_49	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_49;
	assign	VECTOR_5_DI_0_50	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_50;
	assign	VECTOR_5_DI_0_51	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_51;
	assign	VECTOR_5_DI_0_52	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_52;
	assign	VECTOR_5_DI_0_53	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_53;
	assign	VECTOR_5_DI_0_54	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_54;
	assign	VECTOR_5_DI_0_55	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_55;
	assign	VECTOR_5_DI_0_56	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_56;
	assign	VECTOR_5_DI_0_57	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_57;
	assign	VECTOR_5_DI_0_58	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_58;
	assign	VECTOR_5_DI_0_59	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_59;
	assign	VECTOR_5_DI_0_60	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_60;
	assign	VECTOR_5_DI_0_61	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_61;
	assign	VECTOR_5_DI_0_62	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_62;
	assign	VECTOR_5_DI_0_63	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_63;

	assign	VECTOR_6_DI_0_00	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_0;
	assign	VECTOR_6_DI_0_01	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_1;
	assign	VECTOR_6_DI_0_02	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_2;
	assign	VECTOR_6_DI_0_03	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_3;
	assign	VECTOR_6_DI_0_04	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_4;
	assign	VECTOR_6_DI_0_05	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_5;
	assign	VECTOR_6_DI_0_06	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_6;
	assign	VECTOR_6_DI_0_07	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_7;
	assign	VECTOR_6_DI_0_08	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_8;
	assign	VECTOR_6_DI_0_09	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_9;
	assign	VECTOR_6_DI_0_10	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_10;
	assign	VECTOR_6_DI_0_11	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_11;
	assign	VECTOR_6_DI_0_12	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_12;
	assign	VECTOR_6_DI_0_13	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_13;
	assign	VECTOR_6_DI_0_14	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_14;
	assign	VECTOR_6_DI_0_15	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_15;
	assign	VECTOR_6_DI_0_16	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_16;
	assign	VECTOR_6_DI_0_17	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_17;
	assign	VECTOR_6_DI_0_18	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_18;
	assign	VECTOR_6_DI_0_19	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_19;
	assign	VECTOR_6_DI_0_20	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_20;
	assign	VECTOR_6_DI_0_21	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_21;
	assign	VECTOR_6_DI_0_22	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_22;
	assign	VECTOR_6_DI_0_23	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_23;
	assign	VECTOR_6_DI_0_24	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_24;
	assign	VECTOR_6_DI_0_25	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_25;
	assign	VECTOR_6_DI_0_26	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_26;
	assign	VECTOR_6_DI_0_27	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_27;
	assign	VECTOR_6_DI_0_28	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_28;
	assign	VECTOR_6_DI_0_29	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_29;
	assign	VECTOR_6_DI_0_30	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_30;
	assign	VECTOR_6_DI_0_31	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_31;
	assign	VECTOR_6_DI_0_32	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_32;
	assign	VECTOR_6_DI_0_33	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_33;
	assign	VECTOR_6_DI_0_34	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_34;
	assign	VECTOR_6_DI_0_35	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_35;
	assign	VECTOR_6_DI_0_36	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_36;
	assign	VECTOR_6_DI_0_37	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_37;
	assign	VECTOR_6_DI_0_38	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_38;
	assign	VECTOR_6_DI_0_39	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_39;
	assign	VECTOR_6_DI_0_40	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_40;
	assign	VECTOR_6_DI_0_41	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_41;
	assign	VECTOR_6_DI_0_42	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_42;
	assign	VECTOR_6_DI_0_43	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_43;
	assign	VECTOR_6_DI_0_44	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_44;
	assign	VECTOR_6_DI_0_45	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_45;
	assign	VECTOR_6_DI_0_46	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_46;
	assign	VECTOR_6_DI_0_47	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_47;
	assign	VECTOR_6_DI_0_48	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_48;
	assign	VECTOR_6_DI_0_49	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_49;
	assign	VECTOR_6_DI_0_50	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_50;
	assign	VECTOR_6_DI_0_51	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_51;
	assign	VECTOR_6_DI_0_52	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_52;
	assign	VECTOR_6_DI_0_53	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_53;
	assign	VECTOR_6_DI_0_54	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_54;
	assign	VECTOR_6_DI_0_55	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_55;
	assign	VECTOR_6_DI_0_56	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_56;
	assign	VECTOR_6_DI_0_57	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_57;
	assign	VECTOR_6_DI_0_58	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_58;
	assign	VECTOR_6_DI_0_59	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_59;
	assign	VECTOR_6_DI_0_60	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_60;
	assign	VECTOR_6_DI_0_61	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_61;
	assign	VECTOR_6_DI_0_62	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_62;
	assign	VECTOR_6_DI_0_63	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_63;

	assign	VECTOR_7_DI_0_00	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_0;
	assign	VECTOR_7_DI_0_01	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_1;
	assign	VECTOR_7_DI_0_02	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_2;
	assign	VECTOR_7_DI_0_03	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_3;
	assign	VECTOR_7_DI_0_04	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_4;
	assign	VECTOR_7_DI_0_05	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_5;
	assign	VECTOR_7_DI_0_06	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_6;
	assign	VECTOR_7_DI_0_07	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_7;
	assign	VECTOR_7_DI_0_08	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_8;
	assign	VECTOR_7_DI_0_09	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_9;
	assign	VECTOR_7_DI_0_10	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_10;
	assign	VECTOR_7_DI_0_11	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_11;
	assign	VECTOR_7_DI_0_12	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_12;
	assign	VECTOR_7_DI_0_13	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_13;
	assign	VECTOR_7_DI_0_14	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_14;
	assign	VECTOR_7_DI_0_15	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_15;
	assign	VECTOR_7_DI_0_16	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_16;
	assign	VECTOR_7_DI_0_17	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_17;
	assign	VECTOR_7_DI_0_18	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_18;
	assign	VECTOR_7_DI_0_19	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_19;
	assign	VECTOR_7_DI_0_20	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_20;
	assign	VECTOR_7_DI_0_21	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_21;
	assign	VECTOR_7_DI_0_22	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_22;
	assign	VECTOR_7_DI_0_23	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_23;
	assign	VECTOR_7_DI_0_24	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_24;
	assign	VECTOR_7_DI_0_25	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_25;
	assign	VECTOR_7_DI_0_26	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_26;
	assign	VECTOR_7_DI_0_27	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_27;
	assign	VECTOR_7_DI_0_28	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_28;
	assign	VECTOR_7_DI_0_29	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_29;
	assign	VECTOR_7_DI_0_30	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_30;
	assign	VECTOR_7_DI_0_31	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_31;
	assign	VECTOR_7_DI_0_32	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_32;
	assign	VECTOR_7_DI_0_33	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_33;
	assign	VECTOR_7_DI_0_34	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_34;
	assign	VECTOR_7_DI_0_35	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_35;
	assign	VECTOR_7_DI_0_36	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_36;
	assign	VECTOR_7_DI_0_37	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_37;
	assign	VECTOR_7_DI_0_38	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_38;
	assign	VECTOR_7_DI_0_39	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_39;
	assign	VECTOR_7_DI_0_40	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_40;
	assign	VECTOR_7_DI_0_41	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_41;
	assign	VECTOR_7_DI_0_42	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_42;
	assign	VECTOR_7_DI_0_43	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_43;
	assign	VECTOR_7_DI_0_44	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_44;
	assign	VECTOR_7_DI_0_45	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_45;
	assign	VECTOR_7_DI_0_46	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_46;
	assign	VECTOR_7_DI_0_47	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_47;
	assign	VECTOR_7_DI_0_48	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_48;
	assign	VECTOR_7_DI_0_49	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_49;
	assign	VECTOR_7_DI_0_50	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_50;
	assign	VECTOR_7_DI_0_51	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_51;
	assign	VECTOR_7_DI_0_52	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_52;
	assign	VECTOR_7_DI_0_53	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_53;
	assign	VECTOR_7_DI_0_54	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_54;
	assign	VECTOR_7_DI_0_55	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_55;
	assign	VECTOR_7_DI_0_56	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_56;
	assign	VECTOR_7_DI_0_57	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_57;
	assign	VECTOR_7_DI_0_58	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_58;
	assign	VECTOR_7_DI_0_59	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_59;
	assign	VECTOR_7_DI_0_60	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_60;
	assign	VECTOR_7_DI_0_61	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_61;
	assign	VECTOR_7_DI_0_62	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_62;
	assign	VECTOR_7_DI_0_63	=	(CORE_VECTOR_LOAD_TYPE == 1'b1) ? MEMSET_DO_0 : MEMSET_DO_63;


	assign	VECTOR_0_SEL_BLOCK_LOAD	=	MEMSET_SEL_BLOCK_LOAD;
	assign	VECTOR_1_SEL_BLOCK_LOAD	=	MEMSET_SEL_BLOCK_LOAD;
	assign	VECTOR_2_SEL_BLOCK_LOAD	=	MEMSET_SEL_BLOCK_LOAD;
	assign	VECTOR_3_SEL_BLOCK_LOAD	=	MEMSET_SEL_BLOCK_LOAD;
	assign	VECTOR_4_SEL_BLOCK_LOAD	=	MEMSET_SEL_BLOCK_LOAD;
	assign	VECTOR_5_SEL_BLOCK_LOAD	=	MEMSET_SEL_BLOCK_LOAD;
	assign	VECTOR_6_SEL_BLOCK_LOAD	=	MEMSET_SEL_BLOCK_LOAD;
	assign	VECTOR_7_SEL_BLOCK_LOAD	=	MEMSET_SEL_BLOCK_LOAD;


	assign	MEMSET_DI_0		=	((ADDR == 2'b10) & ~WEN)	? DI :
						(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_0_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_00 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_00 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_00 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_00 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_00 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_00 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_00 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_00 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_1		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_1_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_01 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_01 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_01 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_01 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_01 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_01 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_01 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_01 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_2		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_2_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_02 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_02 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_02 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_02 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_02 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_02 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_02 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_02 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_3		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_3_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_03 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_03 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_03 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_03 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_03 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_03 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_03 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_03 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_4		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_4_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_04 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_04 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_04 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_04 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_04 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_04 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_04 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_04 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_5		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_5_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_05 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_05 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_05 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_05 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_05 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_05 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_05 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_05 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_6		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_6_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_06 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_06 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_06 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_06 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_06 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_06 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_06 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_06 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_7		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_7_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_07 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_07 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_07 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_07 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_07 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_07 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_07 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_07 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_8		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_0_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_08 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_08 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_08 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_08 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_08 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_08 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_08 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_08 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_9		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_1_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_09 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_09 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_09 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_09 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_09 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_09 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_09 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_09 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_10		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_2_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_10 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_10 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_10 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_10 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_10 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_10 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_10 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_10 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_11		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_3_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_11 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_11 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_11 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_11 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_11 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_11 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_11 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_11 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_12		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_4_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_12 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_12 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_12 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_12 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_12 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_12 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_12 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_12 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_13		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_5_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_13 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_13 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_13 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_13 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_13 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_13 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_13 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_13 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_14		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_6_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_14 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_14 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_14 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_14 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_14 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_14 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_14 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_14 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_15		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_7_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_15 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_15 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_15 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_15 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_15 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_15 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_15 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_15 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_16		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_0_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_16 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_16 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_16 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_16 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_16 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_16 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_16 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_16 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_17		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_1_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_17 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_17 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_17 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_17 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_17 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_17 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_17 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_17 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_18		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_2_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_18 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_18 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_18 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_18 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_18 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_18 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_18 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_18 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_19		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_3_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_19 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_19 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_19 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_19 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_19 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_19 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_19 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_19 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_20		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_4_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_20 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_20 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_20 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_20 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_20 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_20 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_20 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_20 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_21		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_5_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_21 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_21 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_21 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_21 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_21 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_21 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_21 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_21 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_22		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_6_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_22 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_22 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_22 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_22 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_22 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_22 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_22 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_22 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_23		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_7_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_23 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_23 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_23 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_23 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_23 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_23 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_23 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_23 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_24		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_0_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_24 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_24 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_24 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_24 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_24 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_24 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_24 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_24 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_25		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_1_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_25 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_25 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_25 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_25 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_25 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_25 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_25 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_25 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_26		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_2_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_26 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_26 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_26 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_26 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_26 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_26 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_26 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_26 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_27		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_3_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_27 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_27 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_27 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_27 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_27 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_27 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_27 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_27 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_28		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_4_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_28 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_28 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_28 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_28 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_28 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_28 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_28 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_28 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_29		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_5_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_29 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_29 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_29 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_29 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_29 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_29 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_29 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_29 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_30		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_6_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_30 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_30 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_30 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_30 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_30 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_30 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_30 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_30 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_31		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_7_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_31 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_31 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_31 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_31 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_31 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_31 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_31 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_31 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_32		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_0_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_32 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_32 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_32 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_32 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_32 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_32 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_32 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_32 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_33		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_1_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_33 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_33 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_33 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_33 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_33 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_33 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_33 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_33 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_34		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_2_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_34 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_34 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_34 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_34 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_34 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_34 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_34 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_34 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_35		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_3_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_35 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_35 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_35 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_35 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_35 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_35 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_35 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_35 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_36		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_4_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_36 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_36 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_36 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_36 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_36 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_36 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_36 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_36 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_37		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_5_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_37 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_37 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_37 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_37 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_37 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_37 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_37 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_37 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_38		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_6_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_38 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_38 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_38 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_38 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_38 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_38 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_38 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_38 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_39		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_7_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_39 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_39 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_39 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_39 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_39 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_39 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_39 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_39 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_40		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_0_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_40 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_40 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_40 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_40 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_40 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_40 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_40 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_40 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_41		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_1_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_41 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_41 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_41 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_41 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_41 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_41 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_41 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_41 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_42		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_2_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_42 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_42 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_42 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_42 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_42 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_42 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_42 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_42 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_43		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_3_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_43 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_43 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_43 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_43 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_43 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_43 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_43 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_43 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_44		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_4_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_44 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_44 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_44 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_44 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_44 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_44 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_44 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_44 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_45		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_5_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_45 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_45 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_45 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_45 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_45 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_45 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_45 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_45 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_46		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_6_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_46 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_46 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_46 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_46 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_46 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_46 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_46 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_46 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_47		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_7_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_47 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_47 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_47 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_47 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_47 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_47 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_47 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_47 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_48		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_0_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_48 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_48 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_48 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_48 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_48 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_48 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_48 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_48 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_49		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_1_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_49 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_49 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_49 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_49 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_49 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_49 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_49 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_49 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_50		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_2_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_50 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_50 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_50 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_50 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_50 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_50 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_50 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_50 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_51		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_3_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_51 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_51 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_51 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_51 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_51 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_51 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_51 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_51 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_52		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_4_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_52 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_52 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_52 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_52 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_52 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_52 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_52 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_52 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_53		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_5_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_53 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_53 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_53 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_53 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_53 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_53 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_53 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_53 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_54		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_6_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_54 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_54 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_54 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_54 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_54 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_54 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_54 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_54 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_55		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_7_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_55 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_55 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_55 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_55 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_55 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_55 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_55 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_55 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_56		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_0_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_56 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_56 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_56 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_56 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_56 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_56 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_56 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_56 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_57		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_1_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_57 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_57 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_57 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_57 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_57 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_57 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_57 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_57 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_58		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_2_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_58 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_58 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_58 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_58 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_58 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_58 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_58 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_58 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_59		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_3_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_59 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_59 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_59 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_59 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_59 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_59 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_59 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_59 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_60		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_4_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_60 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_60 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_60 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_60 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_60 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_60 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_60 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_60 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_61		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_5_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_61 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_61 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_61 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_61 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_61 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_61 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_61 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_61 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_62		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_6_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_62 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_62 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_62 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_62 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_62 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_62 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_62 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_62 :
						CORE_DMEM_DI;

	assign	MEMSET_DI_63		=	(CORE_VECTOR_SEL_DO_SUM)	? VECTOR_7_DO_SUM :
						(CORE_VECTOR_EN[0])		? VECTOR_0_DO_0_63 :
						(CORE_VECTOR_EN[1])		? VECTOR_1_DO_0_63 :
						(CORE_VECTOR_EN[2])		? VECTOR_2_DO_0_63 :
						(CORE_VECTOR_EN[3])		? VECTOR_3_DO_0_63 :
						(CORE_VECTOR_EN[4])		? VECTOR_4_DO_0_63 :
						(CORE_VECTOR_EN[5])		? VECTOR_5_DO_0_63 :
						(CORE_VECTOR_EN[6])		? VECTOR_6_DO_0_63 :
						(CORE_VECTOR_EN[7])		? VECTOR_7_DO_0_63 :
						CORE_DMEM_DI;

	
endmodule

module IMEM (
	input	wire	[31:0]	DI,
	input	wire	[11:0]	ADDR,
	input	wire		CSN,
	input	wire		WEN,
	output	wire	[31:0]	DO,

	input	wire		CLK,
	input	wire		RSTn
);


	wire		FF_WEN_D, FF_WEN_Q;

	PipeReg #(1) FF_WEN (
		.CLK(CLK),
		.RST(~RSTn),
		.EN(1'b1),
		.D(FF_WEN_D),
		.Q(FF_WEN_Q));

	assign	FF_WEN_D	=	WEN;


	wire		FF_CSN_D, FF_CSN_Q;

	PipeReg #(1) FF_CSN (
		.CLK(CLK),
		.RST(~RSTn),
		.EN(1'b1),
		.D(FF_CSN_D),
		.Q(FF_CSN_Q));

	assign	FF_CSN_D	=	CSN;


	wire	[1:0]	FF_BANK_D, FF_BANK_Q;

	PipeReg #(2) FF_BANK (
		.CLK(CLK),
		.RST(~RSTn),
		.EN(1'b1),
		.D(FF_BANK_D),
		.Q(FF_BANK_Q));

	assign	FF_BANK_D	=	ADDR[1:0];


	wire	[31:0]	MEM_DO;

	`ifdef mem_sim

	SRAM #(.AWIDTH(12), .BWIDTH(32), .SIZE(4096)) imem_sram_0 (
		.CLK(CLK),
		.CSN(CSN),
		.ADDR(ADDR),
		.WEN(WEN),
		.DI(DI),
		.DOUT(MEM_DO)
	);

	`else

	wire	[9:0]	ADDR_0, ADDR_1, ADDR_2, ADDR_3;
	wire		CSN_0, CSN_1, CSN_2, CSN_3;
	wire		WEN_0, WEN_1, WEN_2, WEN_3;
	wire	[31:0]	MEM_DO_0, MEM_DO_1, MEM_DO_2, MEM_DO_3;

	cmos28lpp_rf1_hd_1024x32m4 mem_inst_0 (
		.A(ADDR_0),
		.D(DI),
		.CLK(CLK),
		.CEN(CSN_0),
		.WEN(WEN_0),
		.DFTRAMBYP(1'b0),
		.EMA(3'b000),
		.EMAW(2'b00),
		.TEN(1'b1),
		.RET1N(1'b1),
		.SI(2'b00),
		.SE(1'b0),
		.Q(MEM_DO_0),
		.SO()
	);

	cmos28lpp_rf1_hd_1024x32m4 mem_inst_1 (
		.A(ADDR_1),
		.D(DI),
		.CLK(CLK),
		.CEN(CSN_1),
		.WEN(WEN_1),
		.DFTRAMBYP(1'b0),
		.EMA(3'b000),
		.EMAW(2'b00),
		.TEN(1'b1),
		.RET1N(1'b1),
		.SI(2'b00),
		.SE(1'b0),
		.Q(MEM_DO_1),
		.SO()
	);	

	cmos28lpp_rf1_hd_1024x32m4 mem_inst_2 (
		.A(ADDR_2),
		.D(DI),
		.CLK(CLK),
		.CEN(CSN_2),
		.WEN(WEN_2),
		.DFTRAMBYP(1'b0),
		.EMA(3'b000),
		.EMAW(2'b00),
		.TEN(1'b1),
		.RET1N(1'b1),
		.SI(2'b00),
		.SE(1'b0),
		.Q(MEM_DO_2),
		.SO()
	);

	cmos28lpp_rf1_hd_1024x32m4 mem_inst_3 (
		.A(ADDR_3),
		.D(DI),
		.CLK(CLK),
		.CEN(CSN_3),
		.WEN(WEN_3),
		.DFTRAMBYP(1'b0),
		.EMA(3'b000),
		.EMAW(2'b00),
		.TEN(1'b1),
		.RET1N(1'b1),
		.SI(2'b00),
		.SE(1'b0),
		.Q(MEM_DO_3),
		.SO()
	);	


	assign	ADDR_0	=	ADDR[11:2];
	assign	ADDR_1	=	ADDR[11:2];
	assign	ADDR_2	=	ADDR[11:2];
	assign	ADDR_3	=	ADDR[11:2];

	assign	CSN_0	=	(ADDR[1:0] == 2'b00) ? CSN : 1'b1;
	assign	CSN_1	=	(ADDR[1:0] == 2'b01) ? CSN : 1'b1;
	assign	CSN_2	=	(ADDR[1:0] == 2'b10) ? CSN : 1'b1;
	assign	CSN_3	=	(ADDR[1:0] == 2'b11) ? CSN : 1'b1;

	assign	WEN_0	=	WEN;
	assign	WEN_1	=	WEN;
	assign	WEN_2	=	WEN;
	assign	WEN_3	=	WEN;

	assign	MEM_DO	=	(FF_BANK_Q == 2'b00) ? MEM_DO_0 :
				(FF_BANK_Q == 2'b01) ? MEM_DO_1 :
				(FF_BANK_Q == 2'b10) ? MEM_DO_2 :
				(FF_BANK_Q == 2'b11) ? MEM_DO_3 :
				32'd0;

	`endif

	assign	DO	=	(FF_WEN_Q & ~FF_CSN_Q) ? MEM_DO : 32'd0;


endmodule


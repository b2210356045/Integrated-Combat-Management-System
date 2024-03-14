`timescale 1us / 1ps

module ECSU(
    input CLK,
    input RST,
    input thunderstorm,
    input [5:0] wind,
    input [1:0] visibility,
    input signed [7:0] temperature,
    output reg severe_weather,
    output reg emergency_landing_alert,
    output reg [1:0] ECSU_state
);

// Your code goes here.
parameter ALL_CLEAR = 2'b00;
parameter CAUTION = 2'b01;
parameter HIGH_ALERT = 2'b10;
parameter EMERGENCY = 2'b11;
reg [1:0] currentState, nextState;

initial
begin
    currentState <= ALL_CLEAR;
    severe_weather <= 0;
    emergency_landing_alert <= 0;
end

always @(posedge CLK)
begin 
    if (RST) begin
        currentState <= ALL_CLEAR;
        severe_weather <= 0;
        emergency_landing_alert <= 0;
    end
    else begin
        currentState <= nextState;
    end
end

always @*
begin
    nextState = currentState;

    case (currentState)
        ALL_CLEAR: begin
            if ((wind>10 && wind<=15) || visibility==2'b01) begin
                nextState = CAUTION;
            end
            if ((thunderstorm==1'b1) || (wind>15) || (temperature>35) || (temperature<-35) || (visibility==2'b11)) begin
                severe_weather = 1;
                nextState = HIGH_ALERT;
            end
        end
        CAUTION: begin
            if (wind<=10 && visibility==2'b00) begin
                nextState = ALL_CLEAR;
            end
            if ((thunderstorm==1'b1) || (wind>15) || (temperature<-35) || (temperature>35) || (visibility==2'b11)) begin
                severe_weather = 1;
                nextState = HIGH_ALERT;
            end
        end
        HIGH_ALERT: begin
            if (thunderstorm==1'b0 && wind<=10 && (temperature>=-35 && temperature<=35) && visibility==2'b01) begin
                severe_weather = 0;
                nextState = CAUTION;
            end
            if ((temperature<-40) || (temperature>40) || wind>20) begin
                emergency_landing_alert = 1;
                nextState = EMERGENCY;
            end
        end
    endcase

    ECSU_state = currentState;
end

endmodule
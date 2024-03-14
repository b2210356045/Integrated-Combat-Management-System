`timescale 1us / 1ps

module ARTAU(
    input radar_echo,
    input scan_for_target,
    input [31:0] jet_speed,
    input [31:0] max_safe_distance,
    input RST,
    input CLK,
    output reg radar_pulse_trigger,
    output reg [31:0] distance_to_target,
    output reg threat_detected,
    output reg [1:0] ARTAU_state
);

// Your code goes here.
parameter IDLE = 2'b00;
parameter EMIT = 2'b01;
parameter LISTEN = 2'b10;
parameter ASSESS = 2'b11;
reg [1:0] currentState, nextState;
real pulse_count;
real pulse_emmision_timer;
real system_timer;
real listen_to_echo_timer;
real status_update_timer;
reg once;
reg once2;
reg once3;
reg once4;
real timex;
real approaching;
real old_distance;

initial
begin
    currentState <= IDLE;
    radar_pulse_trigger <= 0;
    distance_to_target <= 0;
    threat_detected <= 0;
    pulse_count <= 0;
    pulse_emmision_timer <= 0;
    listen_to_echo_timer <= 0;
    status_update_timer <= 0;
    once <= 0;
    once2 <= 0;
    once3 <= 0;
    once4 <= 0;
    timex <= 0;
    approaching <= 0;
    old_distance <= 0;
end

initial
begin
    forever #1 system_timer = $realtime;
end

always @(posedge CLK)
begin 
    if (RST) begin
        currentState <= IDLE;
        radar_pulse_trigger <= 0;
        distance_to_target <= 0;
        threat_detected <= 0;
        pulse_count <= 0;
        pulse_emmision_timer <= 0;
        listen_to_echo_timer <= 0;
        status_update_timer <= 0;
        once <= 0;
        once2 <= 0;
        once3 <= 0;
        once4 <= 0;
        timex <= 0;
        approaching <= 0;
        old_distance <= 0;
    end
    else begin
        currentState <= nextState;
        once <= 0;
        once2 <= 0;
        once3 <= 0;
        once4 <= 0;
    end
end

always @*
begin
    nextState = currentState;
    
    case (currentState)
        IDLE: begin
            if (scan_for_target==1'b1 && once2==1'b0) begin
                if (pulse_count > 0) begin
                    timex = (system_timer - listen_to_echo_timer);
                    distance_to_target = (3 * timex * 100) / 2;
                end
                radar_pulse_trigger = 1;
                pulse_count++;
                pulse_emmision_timer = $realtime;
                once = 1;
                once2 = 1;
                nextState = EMIT;
            end
            if (once==1'b1) begin
                nextState = EMIT;
            end
        end
        EMIT: begin
            if ((system_timer - pulse_emmision_timer)==300 && once2==1'b0) begin
                radar_pulse_trigger = 0;
                listen_to_echo_timer = $realtime;
                once = 1;
                once2 = 1;
                nextState = LISTEN;
            end
            if (once==1'b1) begin
                nextState = LISTEN;
            end
        end
        LISTEN: begin
            if ((system_timer - listen_to_echo_timer)==2000 && scan_for_target==1'b0 && once2==1'b0) begin
                radar_pulse_trigger <= 0;
                distance_to_target <= 0;
                threat_detected <= 0;
                pulse_count <= 0;
                pulse_emmision_timer <= 0;
                listen_to_echo_timer <= 0;
                status_update_timer <= 0;
                timex <= 0;
                approaching <= 0;
                old_distance <= 0;
                once4 <= 1;
                once2 <= 1;
                nextState = IDLE;
            end
            if (radar_echo==1'b1 && pulse_count==1 && once2==1'b0) begin
                if (pulse_count > 0) begin
                    timex = (system_timer - listen_to_echo_timer);
                    distance_to_target = (3 * timex * 100) / 2;
                end
                radar_pulse_trigger = 1;
                pulse_count++;
                pulse_emmision_timer = $realtime;
                once = 1;
                once2 = 1;
                nextState = EMIT;
            end
            if (radar_echo==1'b1 && pulse_count==2 && once2==1'b0) begin
                timex = (system_timer - listen_to_echo_timer);
                old_distance = distance_to_target;
                distance_to_target = (3 * timex * 100) / 2;
                approaching = ((jet_speed * timex * 0.000001) + distance_to_target) - old_distance;
                if (approaching < 0 && distance_to_target < max_safe_distance) begin
                    threat_detected = 1;
                end
                pulse_count = 0;
                status_update_timer = $realtime;
                once3 = 1;
                once2 = 1;
                nextState = ASSESS;
            end
            if (once4==1'b1) begin
                nextState = IDLE;
            end
            if (once==1'b1) begin
                nextState = EMIT;
            end
            if (once3==1'b1) begin
                nextState = ASSESS;
            end
        end
        ASSESS: begin
            if ((system_timer - status_update_timer)==3000 && scan_for_target==1'b0 && once2==1'b0) begin
                radar_pulse_trigger <= 0;
                distance_to_target <= 0;
                threat_detected <= 0;
                pulse_count <= 0;
                pulse_emmision_timer <= 0;
                listen_to_echo_timer <= 0;
                status_update_timer <= 0;
                timex <= 0;
                approaching <= 0;
                old_distance <= 0;
                once <= 1;
                once2 <= 1;
                nextState = IDLE;
            end
            if (scan_for_target==1'b1 && once2==1'b0) begin
                if (pulse_count > 0) begin
                    timex = (system_timer - listen_to_echo_timer);
                    distance_to_target = (3 * timex * 100) / 2;
                end
                radar_pulse_trigger = 1;
                pulse_count++;
                pulse_emmision_timer = $realtime;
                once3 = 1;
                once2 = 1;
                nextState = EMIT;
            end
            if (once==1'b1) begin
                nextState = IDLE;
            end
            if (once3==1'b1) begin
                nextState = EMIT;
            end
        end
    endcase

    ARTAU_state = currentState;
end


endmodule
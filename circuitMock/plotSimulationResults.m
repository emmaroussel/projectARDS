function [] = plotSimulationResults(simOutput,RR,plotCurrents)
% Function which plots Simulink outputs. If plotCurrents option is off
% (=0), then a plot showing pressure, flow, total volume, volume in branch
% H and volume in branch R with time, is generated. If plotCurrents option
% if on (=1), then a plot showing the flows (total, branch H and branch R)
% for the 2nd breath is generated.
%
% INPUTS:
%   simOutput = Simulink simulation output
%   RR = respiratory rate with which the pressure waveform was created (one
%   of the ventilator settings)
%   plotCurrents = option that switches between two possible output plots
% OUTPUTS:
%   Results plot: either pressure-flow-total volume-volume branch H-volume
%   branch R plot, or flow plot with total flow, branch H and branch R
%   flows.
%
% Sep 2022

    if nargin == 2
        plotCurrents = 0;
    elseif nargin < 2
        error('Not enough input arguments.')
    end

    t = simOutput.tout;
    P = squeeze(simOutput.logsout{1}.Values.Data);
    Q = squeeze(simOutput.logsout{3}.Values.Data);
    QH = squeeze(simOutput.logsout{4}.Values.Data);
    QR = squeeze(simOutput.logsout{5}.Values.Data);
    
    %Delineate the 2nd breath
    T = 60/RR;
    indBeg = find(ismembertol(t,T,1e-6));
    indEnd = find(ismembertol(t,2*T,1e-6));
    tBreath = t(indBeg:indEnd);
    
    %Compute volumes by cumulative integral of flow
    V = cumtrapz(t(indBeg:end),Q(indBeg:end));
    VH = cumtrapz(t(indBeg:end),QH(indBeg:end));
    VR = cumtrapz(t(indBeg:end),QR(indBeg:end));
    
    if (plotCurrents)
        p1 = plot(tBreath,Q(indBeg:indEnd),tBreath,QH(indBeg:indEnd),...
            tBreath,QR(indBeg:indEnd),'LineWidth',1.4);
        set(gca,'FontSize',14);
        xlabel('Time [s]')
        ylabel('Flow [mL/s]')
        legend({'Q_{tot}','Q_H','Q_R'},'FontSize',14)
        colors = {[0 0 0],[0.3137 0.6784 0.0549],[0 0 1]};
        [p1(1).Color,p1(2).Color,p1(3).Color] = colors{:};
        if (max(Q(indBeg:indEnd)) < 0.01)
            ymax=0.4;
            ylim([-ymax,ymax])
        end
        grid on
        %title('Total flow and flows in branch H and R for one breath')
    else 
        subplot(5,1,1)
            plot(t,P,'k','LineWidth',1.4)
            a(1) = gca;
            ylabel('Pressure [cmH_2O]')
            ylim([-5,30])
            grid on
        subplot(5,1,2)
            plot(t,Q,'k','LineWidth',1.4)
            a(2) = gca;
            ylabel('Flow [mL/s]')
            if (max(Q(indBeg:indEnd)) < 0.01)
            ymax=0.4;
            ylim([-ymax,ymax])
            end
            grid on
        subplot(5,1,3)
            plot(t(indBeg:end),V,'k','LineWidth',1.4)
            a(3) = gca;
            ylabel('Total Volume [mL]')
            if (max(V) < 0.01)
                ymax=0.04;
                ylim([-ymax,ymax])
            end
            grid on
        subplot(5,1,4)
            plot(t(indBeg:end),VH,'k','LineWidth',1.4)
            a(4) = gca;
            ylabel('Volume H [mL]')
            if (max(V) < 0.01)
                ymax=0.04;
                ylim([-ymax,ymax])
            elseif (max(VH) < 0.01)
                ymax=0.02;
                 ylim([-ymax,ymax])
            end
            grid on
        subplot(5,1,5)
            plot(t(indBeg:end),VR,'k','LineWidth',1.4)
            a(5) = gca;
            ylabel('Volume R [mL]')
            if (max(V) < 0.01)
                ymax=0.04;
                ylim([-ymax,ymax])
            elseif (max(VR) > 0.01)
            else
                ylim([-max(VH)/2,max(VH)])
            end
            xlabel('Time [s]')
            grid on
        linkaxes(a,'x')
    end
end